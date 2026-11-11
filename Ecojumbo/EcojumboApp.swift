import SwiftUI
import UIKit

@main
struct EcojumboApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var bluetooth = JKBluetoothManager()
    @StateObject private var gps = GPSRideManager()

    var body: some Scene {
        WindowGroup {
            EcojumboRootView()
                .environmentObject(bluetooth)
                .environmentObject(gps)
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onChange(of: scenePhase) { _, phase in
                    UIApplication.shared.isIdleTimerDisabled = (phase == .active)
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
        }
    }
}
