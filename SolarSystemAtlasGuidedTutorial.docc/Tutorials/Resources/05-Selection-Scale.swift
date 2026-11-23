import RealityKit

private func applySelection(
    to model: Entity,
    planet: Planet,
    selectedPlanet: Planet?
) {
    let isSelected = selectedPlanet?.id == planet.id
    model.scale = SIMD3(repeating: isSelected ? 1.18 : 1)
}
