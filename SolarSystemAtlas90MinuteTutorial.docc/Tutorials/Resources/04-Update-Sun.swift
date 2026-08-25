private let sunRotationDuration: TimeInterval = 8

private func updateSun(
    in root: Entity,
    elapsedTime: TimeInterval
) {
    let progress = cycleProgress(
        elapsedTime,
        duration: sunRotationDuration
    )
    root.findEntity(named: "sun-model")?.orientation = rotation(
        radians: Float(progress * 2 * .pi)
    )
}
