import Foundation

@main struct CockpitBarMathTests {
    static func main() {
        func near(_ a: Double?, _ b: Double) -> Bool { a.map { abs($0-b) < 0.00001 } ?? false }
        assert(near(CockpitBarMath.unit(78, maximum: 100), 0.78))
        assert(near(CockpitBarMath.unit(66.4, minimum: 50, maximum: 73), 16.4/23))
        assert(near(CockpitBarMath.unit(104, maximum: 200), 0.52))
        assert(near(CockpitBarMath.unit(2.6, maximum: 5), 0.52))
        assert(near(CockpitBarMath.unit(12.4, maximum: 100), 0.124))
        assert(near(CockpitBarMath.odometerCycle(1285, cycle: 1000), 0.285))
        assert(near(CockpitBarMath.unit(0, maximum: 100), 0.0))
        assert(near(CockpitBarMath.unit(-10, maximum: 100), 0.0))
        assert(near(CockpitBarMath.unit(120, maximum: 100), 1.0))
        assert(CockpitBarMath.unit(nil, maximum: 100) == nil)
        assert(CockpitBarMath.unit(Double.nan, maximum: 100) == nil)
        assert(CockpitBarMath.unit(70, maximum: 0) == nil)
        assert(CockpitBarMath.odometerCycle(nil, cycle: 1000) == nil)
        assert(CockpitBarMath.odometerCycle(100, cycle: 0) == nil)
        print("OK — 6 barre reali, normalizzazione, saturazione, misura mancante")
    }
}
