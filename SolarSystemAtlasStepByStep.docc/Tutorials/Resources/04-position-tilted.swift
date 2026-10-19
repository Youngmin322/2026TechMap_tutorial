import Foundation
import RealityKit

enum OrbitPosition {
    static let pointToMeter: Float = 0.001
    static let tabletopTilt: Float = .pi / 10

    static func planetPosition(
        radius: Float,
        diameter: Float,
        angle: Float
    ) -> SIMD3<Float> {
        let depth = sin(angle) * radius
        return SIMD3(
            cos(angle) * radius,
            diameter / 2 - depth * sin(tabletopTilt),
            depth * cos(tabletopTilt)
        )
    }

    static func labelPosition(
        radius: Float,
        diameter: Float,
        angle: Float
    ) -> SIMD3<Float> {
        var position = planetPosition(
            radius: radius,
            diameter: diameter,
            angle: angle
        )
        position.y += diameter / 2 + 0.018
        return position
    }

    static func cycleProgress(
        _ elapsedTime: TimeInterval,
        duration: TimeInterval
    ) -> Double {
        elapsedTime.truncatingRemainder(dividingBy: duration) / duration
    }

    static func rotation(radians: Float) -> simd_quatf {
        simd_quatf(angle: radians, axis: SIMD3(0, 1, 0))
    }
}
