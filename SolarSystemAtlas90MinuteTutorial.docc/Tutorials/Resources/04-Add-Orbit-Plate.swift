private func addOrbitPlate(to root: Entity) {
    let orbitPlate = Entity()
    orbitPlate.name = "orbit-plate"
    orbitPlate.orientation = simd_quatf(
        angle: tabletopTilt,
        axis: SIMD3(1, 0, 0)
    )
    root.addChild(orbitPlate)

    for planet in Planet.starter {
        let radius = Float(planet.orbitRadius) * pointToMeter

        if let orbit = try? makeOrbitRing(radius: radius) {
            orbitPlate.addChild(orbit)
        }
    }
}
