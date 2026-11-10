import SwiftUI

@main
struct EcojumboApp: App {
    @StateObject private var bluetooth = JKBluetoothManager()
    @StateObject private var gps = GPSRideManager()

    var body: some Scene {
        WindowGroup {
            EcojumboRootView()
                .environmentObject(bluetooth)
                .environmentObject(gps)
                .preferredColorScheme(.dark)
        }
    }
}
