updateSun(in: root, elapsedTime: elapsedTime)

for (index, planet) in Planet.starter.enumerated() {
    update(
        planet,
        index: index,
        in: root,
        elapsedTime: elapsedTime
    )
}
