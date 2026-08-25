for (index, planet) in Planet.starter.enumerated() {
    await addPlanet(planet, index: index, to: root)
}
