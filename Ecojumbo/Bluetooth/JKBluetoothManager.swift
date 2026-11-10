import Foundation
import CoreBluetooth
import Combine

struct NearbyPeripheral: Identifiable, Equatable {
    let id: UUID
    let name: String
    let rssi: Int
}

@MainActor
final class JKBluetoothManager: NSObject, ObservableObject, @preconcurrency CBCentralManagerDelegate, @preconcurrency CBPeripheralDelegate {
    @Published private(set) var state = "Bluetooth in inizializzazione"
    @Published private(set) var isScanning = false
    @Published private(set) var isConnected = false
    @Published private(set) var nearby: [NearbyPeripheral] = []
    @Published private(set) var snapshot: JKSnapshot?
    @Published private(set) var deviceInfo: JKDeviceInfo?
    @Published private(set) var frameCount = 0
    @Published private(set) var rawCount = 0
    @Published private(set) var lastError: String?
    @Published var format: JKFrameFormat = .automatic
    @Published var cellCount: Int = 20
    let session = RideSession()

    private var central: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]
    private var connected: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var notifyCharacteristic: CBCharacteristic?
    private var assembler = JKFrameAssembler()
    private var counter: UInt8 = 0

    override init() {
        super.init()
        if let saved = UserDefaults.standard.string(forKey: "ecojumbo.frameFormat"),
           let parsed = JKFrameFormat(rawValue: saved) {
            format = parsed
        }
        let savedCount = UserDefaults.standard.integer(forKey: "ecojumbo.cellCount")
        if (1...24).contains(savedCount) { cellCount = savedCount }
        central = CBCentralManager(delegate: self, queue: .main)
    }

    func scan() {
        guard central.state == .poweredOn else { state = "Attiva Bluetooth e autorizza Ecojumbo"; return }
        nearby = []
        peripherals = [:]
        isScanning = true
        state = "Ricerca BMS Bluetooth…"
        central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func stopScan() {
        central.stopScan()
        isScanning = false
        if !isConnected { state = "Ricerca terminata" }
    }

    func connect(_ device: NearbyPeripheral) {
        guard let peripheral = peripherals[device.id] else { return }
        stopScan()
        if let old = connected { central.cancelPeripheralConnection(old) }
        resetConnection()
        connected = peripheral
        peripheral.delegate = self
        state = "Connessione a \(device.name)…"
        central.connect(peripheral, options: nil)
    }

    func disconnect() {
        if let device = connected { central.cancelPeripheralConnection(device) }
        resetConnection()
        state = "Disconnesso"
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn: state = "Bluetooth pronto"
        case .poweredOff: resetConnection(); state = "Bluetooth spento"
        case .unauthorized: resetConnection(); state = "Permesso Bluetooth negato"
        case .unsupported: resetConnection(); state = "Bluetooth LE non supportato"
        default: state = "Bluetooth non disponibile"
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String)
            ?? peripheral.name ?? "Dispositivo senza nome"
        peripherals[peripheral.identifier] = peripheral
        let record = NearbyPeripheral(id: peripheral.identifier, name: name, rssi: RSSI.intValue)
        if let index = nearby.firstIndex(where: { $0.id == record.id }) { nearby[index] = record }
        else { nearby.append(record) }
        nearby.sort { left, right in
            let leftJK = left.name.uppercased().contains("JK") || left.name.uppercased().contains("BMS")
            let rightJK = right.name.uppercased().contains("JK") || right.name.uppercased().contains("BMS")
            if leftJK != rightJK { return leftJK }
            return left.rssi > right.rssi
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        state = "Connesso via Bluetooth · ricerca servizio JK"
        peripheral.discoverServices([CBUUID(string: "FFE0")])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        resetConnection()
        lastError = error?.localizedDescription ?? "Collegamento non riuscito"
        state = "Connessione fallita"
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        resetConnection()
        state = "BMS scollegato"
        if let error { lastError = error.localizedDescription }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error { lastError = error.localizedDescription; return }
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == CBUUID(string: "FFE0") {
            peripheral.discoverCharacteristics([CBUUID(string: "FFE1")], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error { lastError = error.localizedDescription; return }
        for characteristic in service.characteristics ?? [] where characteristic.uuid == CBUUID(string: "FFE1") {
            if characteristic.properties.contains(.notify) || characteristic.properties.contains(.indicate) {
                notifyCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.properties.contains(.writeWithoutResponse) || characteristic.properties.contains(.write) {
                writeCharacteristic = characteristic
            }
        }
        if notifyCharacteristic == nil || writeCharacteristic == nil {
            state = "Connesso, ma servizio JK non compatibile"
            lastError = "Servizio FFE0 / caratteristiche FFE1 non trovati o non compatibili."
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error { lastError = error.localizedDescription; return }
        guard characteristic.isNotifying else { return }
        state = "In ascolto: richieste di sola lettura"
        // These are ONLY documented read requests: no protection settings are altered.
        sendRead(0x96)
        sendRead(0x97)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error { lastError = error.localizedDescription; return }
        guard let value = characteristic.value else { return }
        rawCount += 1
        for frame in assembler.append(value) {
            frameCount += 1
            switch frame[4] {
            case 0x02:
                if let live = JKProtocol.decode(frame, format: format, cellCount: cellCount) {
                    snapshot = live
                    session.add(live)
                    lastError = nil
                    state = "BMS JK · dati verificati"
                } else {
                    state = "Frame ricevuti: formato da verificare"
                    lastError = "Frame JK valido, ma i dati non corrispondono al formato selezionato. Prova JK02 24S o 32S; non viene mostrato alcun valore incerto."
                }
            case 0x03:
                deviceInfo = JKProtocol.deviceInfo(frame)
            default: break
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error { lastError = error.localizedDescription }
    }

    func requestRead() {
        guard isConnected else { return }
        sendRead(0x96)
        sendRead(0x97)
    }

    private func sendRead(_ opcode: UInt8) {
        guard let connected, let characteristic = writeCharacteristic else { return }
        counter &+= 1
        let payload = JKProtocol.request(opcode, counter: counter)
        let writeType: CBCharacteristicWriteType = characteristic.properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse
        connected.writeValue(payload, for: characteristic, type: writeType)
    }

    func applyFormat(_ next: JKFrameFormat, cells: Int) {
        format = next
        cellCount = max(1, min(cells, 24))
        snapshot = nil
        session.pause()
        assembler.reset()
        if isConnected { state = "Formato aggiornato: attendi una lettura reale" }
    }

    private func resetConnection() {
        isConnected = false
        snapshot = nil
        deviceInfo = nil
        writeCharacteristic = nil
        notifyCharacteristic = nil
        connected = nil
        assembler.reset()
        session.pause()
    }
}
