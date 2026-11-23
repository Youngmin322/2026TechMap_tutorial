import RealityKit
import RealityKitContent

private let pointToMeter: Float = 0.001

private func fittedModel(
    named assetName: String,
    targetDiameter: Float
) async throws -> Entity {
    let source = try await Entity(
        named: assetName,
        in: realityKitContentBundle
    )
    let bounds = source.visualBounds(relativeTo: source)
    let largestDimension = max(
        bounds.extents.x,
        bounds.extents.y,
        bounds.extents.z
    )
    let scale = largestDimension > 0
        ? targetDiameter / largestDimension
        : 1

    source.scale = SIMD3(repeating: scale)
    source.position = -bounds.center * scale

    let container = Entity()
    container.addChild(source)
    return container
}

private func prepareForInput(
    _ model: Entity,
    planet: Planet
) {
    let diameter = Float(planet.displaySize) * pointToMeter

    model.name = "model-\(planet.id)"
    model.components.set(InputTargetComponent())
    model.components.set(
        CollisionComponent(
            shapes: [.generateSphere(radius: diameter / 2)]
        )
    )
    model.components.set(HoverEffectComponent())
}
