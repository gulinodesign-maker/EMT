import Foundation

@main
struct Tests {
    static func set16(_ bytes: inout [UInt8], _ offset: Int, _ value: UInt16) {
        bytes[offset] = UInt8(truncatingIfNeeded: value)
        bytes[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
    }
    static func set32(_ bytes: inout [UInt8], _ offset: Int, _ value: UInt32) {
        for i in 0..<4 { bytes[offset + i] = UInt8(truncatingIfNeeded: value >> (i*8)) }
    }
    static func frame(_ kind: JKFrameFormat) -> [UInt8] {
        var b = [UInt8](repeating: 0, count: 300)
        b.replaceSubrange(0..<4, with: JKProtocol.header)
        b[4] = 2
        for i in 0..<20 { set16(&b, 6 + i*2, 3220) }
        let offset = kind == .jk02_32s ? 32 : 0
        set32(&b, 118 + offset, 64_400)
        set32(&b, 126 + offset, UInt32(bitPattern: -20_500))
        set16(&b, 130 + offset, 250)
        set16(&b, 132 + offset, 260)
        b[141+offset] = 83
        set32(&b, 142 + offset, 170_980)
        set32(&b, 146 + offset, 206_000)
        b[299] = b[0..<299].reduce(0) { $0 &+ $1 }
        return b
    }
    static func main() {
        for kind in [JKFrameFormat.jk02_24s, .jk02_32s] {
            let bytes = frame(kind)
            assert(JKProtocol.valid(bytes))
            let parsed = JKProtocol.decode(bytes, format: .automatic, cellCount: 20)
            assert(parsed != nil, "Auto detection failed for \(kind)")
            assert(parsed!.format == kind)
            assert(parsed!.soc == 83)
            assert(parsed!.cells.count == 20)
            assert(abs(parsed!.voltage - 64.4) < 0.001)
            assert(abs(parsed!.current + 20.5) < 0.001)
            assert(abs(parsed!.ratedAh - 206) < 0.001)
            assert(abs(parsed!.remainingAh - 170.98) < 0.001)
            assert(JKProtocol.decode(bytes, format: (kind == .jk02_24s ? .jk02_32s : .jk02_24s), cellCount: 20) == nil)
            var corrupted = bytes
            corrupted[42] ^= 0x40
            assert(!JKProtocol.valid(corrupted))
            assert(JKProtocol.decode(corrupted, format: .automatic, cellCount: 20) == nil)
            var assembler = JKFrameAssembler()
            assert(assembler.append(Data(bytes[0..<10])).isEmpty)
            assert(assembler.append(Data(bytes[10..<117])).isEmpty)
            let frames = assembler.append(Data(bytes[117..<300]))
            assert(frames.count == 1 && frames[0] == bytes)
            assert(assembler.append(Data(bytes)).count == 1)
        }
        let request = [UInt8](JKProtocol.request(0x97, counter: 1))
        assert(request.count == 20)
        assert(Array(request[0..<4]) == [0xAA, 0x55, 0x90, 0xEB])
        assert(request[4] == 0x97)
        assert(request[19] == request[0..<19].reduce(0) { $0 &+ $1 })
        print("OK — JK02 24S/32S, checksum, frame assembly, read-only commands")
    }
}
