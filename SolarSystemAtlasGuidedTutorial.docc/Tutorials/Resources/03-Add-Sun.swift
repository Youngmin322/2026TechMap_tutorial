private let sunDiameter: Float = 0.088

private func addSun(to root: Entity) async {
    guard let sun = try? await fittedModel(
        named: "Sun",
        targetDiameter: sunDiameter
    ) else {
        return
    }

    sun.name = "sun-model"
    sun.position.y = sunDiameter / 2
    root.addChild(sun)
}
