import SwiftUI
import RealityKit
import RealityKitContent

struct SolarSystemAtlasView: View {
    var body: some View {
        RealityView { content in
            let root = Entity()
            root.name = "solar-system"
            content.add(root)
        }
    }

    private func fittedModel(
        named assetName: String,
        targetDiameter: Float
    ) async throws -> Entity {
        let source = try await Entity(
            named: assetName,
            in: realityKitContentBundle
        )
        let bounds = source.visualBounds(relativeTo: source)
        let largest = max(
            bounds.extents.x,
            bounds.extents.y,
            bounds.extents.z
        )
        let scale = largest > 0 ? targetDiameter / largest : 1

        source.scale = SIMD3(repeating: scale)
        source.position = -bounds.center * scale

        let container = Entity()
        container.addChild(source)
        return container
    }
}
