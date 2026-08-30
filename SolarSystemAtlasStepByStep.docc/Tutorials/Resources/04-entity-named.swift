import RealityKit

func preparePlanetEntity(
    _ model: Entity,
    planet: Planet
) {
    model.name = "model-\(planet.id)"
}
