import RealityKit

func planetPosition(
    radius: Float,
    diameter: Float,
    angle: Float
) -> SIMD3<Float> {
    SIMD3(
        cos(angle) * radius,
        diameter / 2,
        sin(angle) * radius
    )
}
