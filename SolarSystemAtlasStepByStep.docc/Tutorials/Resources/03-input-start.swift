import RealityKit

func prepareForSelection(
    _ entity: Entity,
    planet: Planet
) {
    entity.name = "model-\(planet.id)"
}
