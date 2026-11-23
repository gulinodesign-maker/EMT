import Foundation

@main struct VehicleInclinationMathTests {
    static func main() {
        func near(_ value: Double, _ expected: Double, tolerance: Double = 0.000001) {
            assert(abs(value - expected) < tolerance, "Expected \(expected), got \(value)")
        }
        func radians(_ degrees: Double) -> Double { degrees * Double.pi / 180 }
        func gravity(roll: Double, pitch: Double, left: Bool) -> VehicleGravityVector {
            let r = radians(roll)
            let p = radians(pitch)
            return VehicleGravityVector(x: (left ? 1 : -1) * cos(r) * cos(p),
                                        y: (left ? 1 : -1) * sin(r) * cos(p),
                                        z: -sin(p))
        }

        for left in [false, true] {
            let level = gravity(roll: 0, pitch: 0, left: left)
            for (roll, pitch) in [(0.0, 0.0), (27, 0), (-22, 0),
                                  (0, 18), (0, -16), (12, 23), (-14, -20)] {
                let g = gravity(roll: roll, pitch: pitch, left: left)
                guard let angles = VehicleInclinationMath.angles(gravity: g, landscapeLeft: left,
                                                                zeroGravity: level) else {
                    fatalError("Missing measurement")
                }
                near(angles.rollDegrees, roll)
                near(angles.pitchDegrees, pitch)
            }
        }

        // Display rivolto al posteriore: il muso che SALE restituisce
        // beccheggio positivo; quando il muso SCENDE il segno è negativo.
        // Il rollio non deve cambiare durante una rotazione solo longitudinale.
        for left in [false, true] {
            let level = gravity(roll: 0, pitch: 0, left: left)
            let noseUp = VehicleInclinationMath.angles(
                gravity: gravity(roll: 0, pitch: 15, left: left),
                landscapeLeft: left, zeroGravity: level)!
            let noseDown = VehicleInclinationMath.angles(
                gravity: gravity(roll: 0, pitch: -12, left: left),
                landscapeLeft: left, zeroGravity: level)!
            near(noseUp.pitchDegrees, 15)
            near(noseDown.pitchDegrees, -12)
            near(noseUp.rollDegrees, 0)
            near(noseDown.rollDegrees, 0)
        }

        // The mount may be 25° tilted while the car is on level ground.
        let baseline = gravity(roll: 0, pitch: 25, left: false)
        let moved = gravity(roll: 0, pitch: 40, left: false)
        let calibrated = VehicleInclinationMath.angles(gravity: moved, landscapeLeft: false,
                                                      zeroGravity: baseline)!
        near(calibrated.pitchDegrees, 15)
        near(calibrated.rollDegrees, 0)

        let sideBaseline = gravity(roll: 12, pitch: 0, left: false)
        let sideMoved = gravity(roll: 30, pitch: 0, left: false)
        let side = VehicleInclinationMath.angles(gravity: sideMoved, landscapeLeft: false,
                                                zeroGravity: sideBaseline)!
        near(side.rollDegrees, 18)
        near(side.pitchDegrees, 0)

        // Never invent vehicle angles until AZZERA has established the
        // flat-ground reference; reject invalid sensor samples.
        assert(VehicleInclinationMath.angles(gravity: gravity(roll: 0, pitch: 0, left: false),
                                            landscapeLeft: false, zeroGravity: nil) == nil)
        assert(VehicleInclinationMath.angles(gravity: .init(x: .nan, y: 0, z: 1),
                                            landscapeLeft: false,
                                            zeroGravity: gravity(roll: 0, pitch: 0, left: false)) == nil)
        print("OK — rear-facing pitch sign, roll unchanged, gravity degrees and calibration")
    }
}
