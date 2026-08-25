import SwiftUI
import RealityKit
import RealityKitContent

struct SolarSystemAtlasView: View {
    private let pointToMeter: Float = 0.001
    private let sunDiameter: Float = 0.088
    private let tabletopTilt: Float = .pi / 10

    var body: some View {
        RealityView { content in
            let root = Entity()
            root.name = "solar-system-root"
            content.add(root)

            await addSun(to: root)

            for (index, planet) in Planet.starter.enumerated() {
                await addPlanet(planet, index: index, to: root)
            }
        }
    }

    private func addSun(to root: Entity) async {
        guard let sun = try? await fittedModel(
            named: "Sun",
            targetDiameter: sunDiameter
        ) else {
            return
        }

        sun.name = "sun-model"
        sun.position.y = sunDiameter / 2
        root.addChild(sun)
    }

    private func addPlanet(
        _ planet: Planet,
        index: Int,
        to root: Entity
    ) async {
        let diameter = Float(planet.displaySize) * pointToMeter

        guard let model = try? await fittedModel(
            named: planet.assetName,
            targetDiameter: diameter
        ) else {
            return
        }

        let radius = Float(planet.orbitRadius) * pointToMeter
        let angle = Float(Double(index) * .pi / 4)

        model.name = "model-\(planet.id)"
        model.position = planetPosition(
            radius: radius,
            diameter: diameter,
            angle: angle
        )
        root.addChild(model)
    }

    private func planetPosition(
        radius: Float,
        diameter: Float,
        angle: Float
    ) -> SIMD3<Float> {
        let depth = sin(angle) * radius

        return SIMD3(
            cos(angle) * radius,
            diameter / 2 - depth * sin(tabletopTilt),
            depth * cos(tabletopTilt)
        )
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
}
