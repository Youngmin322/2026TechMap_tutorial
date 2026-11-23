private let tabletopTilt: Float = .pi / 10

private func planetPosition(
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
