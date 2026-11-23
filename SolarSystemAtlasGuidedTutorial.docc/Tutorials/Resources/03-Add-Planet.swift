private let pointToMeter: Float = 0.001

private func addPlanet(
    _ planet: Planet,
    index: Int,
    to root: Entity
) async {
    let diameter = Float(planet.displaySize) * pointToMeter

    guard let model = try? await fittedModel(
        named: planet.assetName,
        targetDiameter: diameter
    ) else {
        return
    }

    let radius = Float(planet.orbitRadius) * pointToMeter
    let angle = Float(Double(index) * .pi / 4)

    model.name = "model-\(planet.id)"
    model.position = planetPosition(
        radius: radius,
        diameter: diameter,
        angle: angle
    )
    root.addChild(model)
}
