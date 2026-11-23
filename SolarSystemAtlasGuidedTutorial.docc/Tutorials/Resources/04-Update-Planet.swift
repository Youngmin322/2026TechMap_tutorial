private func update(
    _ planet: Planet,
    index: Int,
    in root: Entity,
    elapsedTime: TimeInterval
) {
    let orbitProgress = cycleProgress(
        elapsedTime,
        duration: planet.orbitDuration
    )
    let startOffset = Double(index) * .pi / 4
    let orbitAngle = startOffset + orbitProgress * 2 * .pi

    let spinProgress = cycleProgress(
        elapsedTime,
        duration: planet.rotationDuration
    )
    let spinAngle = spinProgress * 2 * .pi
        * planet.rotationDirection

    guard let model = root.findEntity(
        named: "model-\(planet.id)"
    ) else {
        return
    }

    let radius = Float(planet.orbitRadius) * pointToMeter
    let diameter = Float(planet.displaySize) * pointToMeter
    model.position = planetPosition(
        radius: radius,
        diameter: diameter,
        angle: Float(orbitAngle)
    )
    model.orientation = rotation(radians: Float(spinAngle))
}
