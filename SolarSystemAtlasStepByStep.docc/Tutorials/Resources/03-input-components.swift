import RealityKit

func prepareForSelection(
    _ entity: Entity,
    planet: Planet
) {
    entity.name = "model-\(planet.id)"
    entity.components.set(InputTargetComponent())
    entity.components.set(
        CollisionComponent(
            shapes: [.generateSphere(radius: 0.04)]
        )
    )
    entity.components.set(HoverEffectComponent())
}
