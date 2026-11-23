import RealityKit

private func prepareForInput(
    _ model: Entity,
    planet: Planet,
    diameter: Float
) {
    model.name = "model-\(planet.id)"
    model.components.set(InputTargetComponent())
    model.components.set(
        CollisionComponent(
            shapes: [.generateSphere(radius: diameter / 2)]
        )
    )
    model.components.set(HoverEffectComponent())
}
