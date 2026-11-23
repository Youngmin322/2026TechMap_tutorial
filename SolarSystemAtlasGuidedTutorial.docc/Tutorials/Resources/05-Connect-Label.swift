import RealityKit

private func addLabel(
    for planet: Planet,
    radius: Float,
    diameter: Float,
    angle: Float,
    to root: Entity,
    attachments: RealityViewAttachments
) {
    if let label = attachments.entity(for: planet.id) {
        label.name = "label-\(planet.id)"
        label.position = labelPosition(
            radius: radius,
            diameter: diameter,
            angle: angle
        )
        root.addChild(label)
    }
}

private func labelPosition(
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
