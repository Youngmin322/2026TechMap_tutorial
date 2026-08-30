import RealityKit
import RealityKitContent

func fittedModel(
    named assetName: String,
    targetDiameter: Float
) async throws -> Entity {
    try await Entity(
        named: assetName,
        in: realityKitContentBundle
    )
}
