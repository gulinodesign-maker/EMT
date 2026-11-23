import Foundation

/// Gravity in the iPhone's fixed Core Motion device axes, in g units.
struct VehicleGravityVector: Equatable {
    let x: Double
    let y: Double
    let z: Double

    fileprivate var magnitude: Double { sqrt(x * x + y * y + z * z) }
    fileprivate var isValid: Bool {
        x.isFinite && y.isFinite && z.isFinite && (0.5...1.5).contains(magnitude)
    }
    fileprivate var unit: Self {
        let size = magnitude
        return Self(x: x / size, y: y / size, z: z / size)
    }
}

struct VehicleInclinationAngles: Equatable {
    /// Positive when the vehicle's right side is lower (rear view, clockwise).
    let rollDegrees: Double
    /// Positive when the vehicle nose is higher (side view).
    let pitchDegrees: Double
}

/// Physical gravity-based slopes, independent of Core Motion's relative Euler angles.
/// The phone must be fixed with the display facing the driver and the screen's
/// right-hand side aligned with the vehicle's right-hand side.
/// AZZERA, when parked on level ground, compensates a tilted phone mount.
enum VehicleInclinationMath {
    private static func dot(_ a: VehicleGravityVector, _ b: VehicleGravityVector) -> Double {
        a.x * b.x + a.y * b.y + a.z * b.z
    }

    private static func cross(_ a: VehicleGravityVector, _ b: VehicleGravityVector) -> VehicleGravityVector {
        VehicleGravityVector(x: a.y * b.z - a.z * b.y,
                             y: a.z * b.x - a.x * b.z,
                             z: a.x * b.y - a.y * b.x)
    }

    /// A reference supplied by AZZERA is required for truthful vehicle angles.
    /// Without a level-ground reference the phone's mounting tilt is unknown.
    static func angles(gravity: VehicleGravityVector,
                       landscapeLeft: Bool,
                       zeroGravity: VehicleGravityVector?) -> VehicleInclinationAngles? {
        guard gravity.isValid, let zeroGravity, zeroGravity.isValid else { return nil }

        // Screen coordinates differ in the two landscape interface orientations.
        // Never use UIDeviceOrientation: its left/right names are reversed relative
        // to UIInterfaceOrientation. In interface landscapeLeft screen-right is device +Y.
        let displayRight = VehicleGravityVector(x: 0, y: landscapeLeft ? 1 : -1, z: 0)
        let reference = zeroGravity.unit
        let up = VehicleGravityVector(x: -reference.x, y: -reference.y, z: -reference.z)

        // Project screen-right into the horizontal plane at calibration.
        // This removes the initial mounting lean, rather than treating the
        // orientation when the panel opens as the car's level reference.
        let alignment = dot(displayRight, up)
        let rightCandidate = VehicleGravityVector(x: displayRight.x - up.x * alignment,
                                                  y: displayRight.y - up.y * alignment,
                                                  z: displayRight.z - up.z * alignment)
        guard rightCandidate.magnitude > 0.2 else { return nil }
        let right = rightCandidate.unit
        // Right × Up points toward the driver; Up × Right points to the nose.
        let forward = cross(up, right)
        let g = gravity.unit
        let vertical = -dot(g, up)
        let lateral = dot(g, right)
        let longitudinal = dot(g, forward)

        // Orthogonal gravity projections give angles in physical degrees.
        // The pitch denominator includes roll to avoid inflated readings.
        let roll = atan2(lateral, vertical) * 180 / Double.pi
        let pitch = atan2(-longitudinal, hypot(lateral, vertical)) * 180 / Double.pi
        guard roll.isFinite && pitch.isFinite else { return nil }
        return VehicleInclinationAngles(rollDegrees: roll, pitchDegrees: pitch)
    }
}
