import Foundation

/// JK02 BLE data frames; this is not the JK04 (older float) wire format.
/// These are READ-only commands and decoding. No setting writes are implemented.
enum JKFrameFormat: String, CaseIterable, Identifiable {
    case automatic = "Automatico"
    case jk02_24s = "JK02 24S"
    case jk02_32s = "JK02 32S"
    var id: String { rawValue }
    var offset: Int? {
        switch self {
        case .automatic: return nil
        case .jk02_24s: return 0
        case .jk02_32s: return 32
        }
    }
}

struct JKSnapshot: Equatable {
    let date: Date
    let format: JKFrameFormat
    let voltage: Double
    /// Protocol convention: positive charging, negative discharging.
    let current: Double
    let soc: Int
    let remainingAh: Double
    let ratedAh: Double
    let temperatures: [Double]
    let cells: [Double]
    let errorBits: UInt32
    var power: Double { voltage * current }
    var deltaCellMillivolts: Double {
        guard let minV = cells.min(), let maxV = cells.max() else { return 0 }
        return (maxV - minV) * 1000
    }
}

struct JKDeviceInfo {
    let name: String
    let hardware: String
    let firmware: String
}

enum JKProtocol {
    static let header: [UInt8] = [0x55, 0xAA, 0xEB, 0x90]
    static let frameLength = 300

    static func request(_ command: UInt8, counter: UInt8) -> Data {
        // Only 0x96 (read settings) and 0x97 (read device info).
        precondition(command == 0x96 || command == 0x97)
        var bytes = [UInt8](repeating: 0, count: 20)
        bytes.replaceSubrange(0..<4, with: [0xAA, 0x55, 0x90, 0xEB])
        bytes[4] = command
        bytes[16] = counter
        bytes[19] = bytes[0..<19].reduce(0) { $0 &+ $1 }
        return Data(bytes)
    }

    static func valid(_ bytes: [UInt8]) -> Bool {
        guard bytes.count == frameLength, Array(bytes[0..<4]) == header else { return false }
        return bytes[0..<299].reduce(0) { $0 &+ $1 } == bytes[299]
    }

    static func deviceInfo(_ bytes: [UInt8]) -> JKDeviceInfo? {
        guard valid(bytes), bytes[4] == 0x03 else { return nil }
        func string(_ start: Int, _ length: Int) -> String {
            let contents = bytes[start..<(start+length)].prefix { $0 != 0 }
            return String(bytes: contents, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        return JKDeviceInfo(name: string(46, 16), hardware: string(22, 8), firmware: string(30, 8))
    }

    static func decode(_ bytes: [UInt8], format: JKFrameFormat, cellCount: Int, now: Date = Date()) -> JKSnapshot? {
        guard valid(bytes), bytes[4] == 0x02, (1...24).contains(cellCount) else { return nil }
        let candidates: [(JKFrameFormat, Int)] = switch format {
        case .automatic: [(.jk02_24s, 0), (.jk02_32s, 32)]
        case .jk02_24s: [(.jk02_24s, 0)]
        case .jk02_32s: [(.jk02_32s, 32)]
        }
        let decoded = candidates.compactMap { candidate -> JKSnapshot? in
            let (kind, offset) = candidate
            let cells = (0..<cellCount).map { Double(u16(bytes, 6 + $0 * 2)) / 1000 }
            guard cells.allSatisfy({ (2.0...3.85).contains($0) }) else { return nil }
            let voltage = Double(u32(bytes, 118 + offset)) / 1000
            let current = Double(Int32(bitPattern: u32(bytes, 126 + offset))) / 1000
            let soc = Int(bytes[141 + offset])
            let remaining = Double(u32(bytes, 142 + offset)) / 1000
            let rated = Double(u32(bytes, 146 + offset)) / 1000
            let temps = [130 + offset, 132 + offset].map { Double(Int16(bitPattern: u16(bytes, $0))) / 10 }
            let errors = kind == .jk02_32s ? u32(bytes, 166) : UInt32(u16(bytes, 136))
            // Reject offsets that happen to decode as plausible garbage.
            guard (20...120).contains(voltage),
                  abs(voltage - cells.reduce(0, +)) <= 4.0,
                  abs(current) <= 600,
                  (0...100).contains(soc),
                  (0...2000).contains(rated), rated > 0,
                  remaining >= 0, remaining <= rated * 1.05,
                  temps.allSatisfy({ (-40...110).contains($0) }) else { return nil }
            return JKSnapshot(date: now, format: kind, voltage: voltage, current: current,
                              soc: soc, remainingAh: remaining, ratedAh: rated,
                              temperatures: temps, cells: cells, errorBits: errors)
        }
        // Automatic mode intentionally refuses to guess when both formats look plausible.
        return decoded.count == 1 ? decoded[0] : nil
    }

    private static func u16(_ bytes: [UInt8], _ offset: Int) -> UInt16 {
        UInt16(bytes[offset]) | (UInt16(bytes[offset+1]) << 8)
    }
    private static func u32(_ bytes: [UInt8], _ offset: Int) -> UInt32 {
        UInt32(bytes[offset]) | (UInt32(bytes[offset+1]) << 8) |
        (UInt32(bytes[offset+2]) << 16) | (UInt32(bytes[offset+3]) << 24)
    }
}

/// Assembles 300-byte JK02 notifications; rejects invalid checksums.
struct JKFrameAssembler {
    private var bytes: [UInt8] = []

    mutating func reset() { bytes.removeAll(keepingCapacity: false) }

    mutating func append(_ chunk: Data) -> [[UInt8]] {
        bytes.append(contentsOf: chunk)
        if bytes.count > 2048 { bytes = Array(bytes.suffix(600)) }
        var frames: [[UInt8]] = []
        while true {
            guard let start = bytes.indices.first(where: { index in
                index + 4 <= bytes.count && Array(bytes[index..<(index+4)]) == JKProtocol.header
            }) else {
                // Preserve possible split header across BLE notifications.
                bytes = Array(bytes.suffix(min(bytes.count, 3)))
                break
            }
            if start > 0 { bytes.removeFirst(start) }
            guard bytes.count >= JKProtocol.frameLength else { break }
            let candidate = Array(bytes.prefix(JKProtocol.frameLength))
            if JKProtocol.valid(candidate) {
                frames.append(candidate)
                bytes.removeFirst(JKProtocol.frameLength)
            } else {
                bytes.removeFirst(1)
            }
        }
        return frames
    }
}
