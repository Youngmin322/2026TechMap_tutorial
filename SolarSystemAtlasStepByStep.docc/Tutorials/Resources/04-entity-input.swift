import RealityKit

func preparePlanetEntity(
    _ model: Entity,
    planet: Planet
) {
    let diameter = Float(planet.displaySize) * 0.001

    model.name = "model-\(planet.id)"
    model.components.set(InputTargetComponent())
    model.components.set(
        CollisionComponent(
            shapes: [.generateSphere(radius: diameter / 2)]
        )
    )
    model.components.set(HoverEffectComponent())
}
