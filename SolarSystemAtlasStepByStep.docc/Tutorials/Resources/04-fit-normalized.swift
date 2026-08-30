import RealityKit
import RealityKitContent

func fittedModel(
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
