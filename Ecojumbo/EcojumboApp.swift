import SwiftUI
import UIKit


// La Home GPS rimane esclusivamente landscape. Le altre cinque sezioni
// supportano anche portrait. UIKit applica la maschera ad ogni transizione:
// l'abilitazione generale nel plist non deve sbloccare il tachimetro.
@MainActor
enum EcojumboOrientationPolicy {
    private(set) static var cockpitOnly = true

    static var supported: UIInterfaceOrientationMask {
        cockpitOnly ? .landscape : .allButUpsideDown
    }

    static func update(for tab: EcoTab, force: Bool = false) {
        let newCockpitOnly = tab == .gps
        guard force || cockpitOnly != newCockpitOnly else { return }
        cockpitOnly = newCockpitOnly

        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            guard scene.activationState != .background else { continue }
            for window in scene.windows {
                window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
            let mask = supported
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { error in
                NSLog("Ecojumbo orientation request denied: %@", error.localizedDescription)
            }
        }
    }
}

@MainActor
final class EcojumboOrientationAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        EcojumboOrientationPolicy.supported
    }
}

@main
struct EcojumboApp: App {
    @UIApplicationDelegateAdaptor(EcojumboOrientationAppDelegate.self) private var orientationDelegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var bluetooth = JKBluetoothManager()
    @StateObject private var gps = GPSRideManager()
    @StateObject private var powerMotion = EcoPowerMotionManager()

    var body: some Scene {
        WindowGroup {
            EcojumboRootView()
                .environmentObject(bluetooth)
                .environmentObject(gps)
                .environmentObject(powerMotion)
                .onOpenURL { url in
                    EcoMusicManager.shared.handleSpotifyCallback(url)
                }
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                    powerMotion.start()
                }
                .onChange(of: scenePhase) { _, phase in
                    UIApplication.shared.isIdleTimerDisabled = (phase == .active)
                    if phase == .active {
                        gps.retryLocation()
                        powerMotion.start()
                    } else {
                        powerMotion.stop()
                    }
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                    powerMotion.stop()
                }
        }
    }
}
