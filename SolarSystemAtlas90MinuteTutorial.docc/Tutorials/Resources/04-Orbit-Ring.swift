private func makeOrbitRing(radius: Float) throws -> ModelEntity {
    let segments = 192
    let halfWidth: Float = 0.00075
    var positions: [SIMD3<Float>] = []
    var indices: [UInt32] = []

    for segment in 0...segments {
        let angle = Float(segment) / Float(segments) * 2 * .pi
        let direction = SIMD2<Float>(cos(angle), sin(angle))
        let inner = direction * (radius - halfWidth)
        let outer = direction * (radius + halfWidth)

        positions.append(SIMD3(inner.x, 0, inner.y))
        positions.append(SIMD3(outer.x, 0, outer.y))
    }

    for segment in 0..<segments {
        let inner = UInt32(segment * 2)
        let outer = inner + 1
        let nextInner = inner + 2
        let nextOuter = inner + 3
        indices.append(contentsOf: [
            inner, outer, nextOuter,
            inner, nextOuter, nextInner
        ])
    }

    var descriptor = MeshDescriptor(name: "OrbitRing")
    descriptor.positions = MeshBuffers.Positions(positions)
    descriptor.primitives = .triangles(indices)

    let mesh = try MeshResource.generate(from: [descriptor])
    var material = UnlitMaterial(
        color: UIColor.white.withAlphaComponent(0.28)
    )
    material.faceCulling = .none
    return ModelEntity(mesh: mesh, materials: [material])
}
