private func planet(for entity: Entity) -> Planet? {
    var candidate: Entity? = entity

    while let current = candidate {
        if let planet = Planet.starter.first(where: {
            "model-\($0.id)" == current.name
        }) {
            return planet
        }

        candidate = current.parent
    }

    return nil
}
