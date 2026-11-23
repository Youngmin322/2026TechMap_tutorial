import SwiftUI
import RealityKit
import RealityKitContent

struct SolarSystemAtlasView: View {
    private let tilt: Float = .pi / 10
    @State private var startDate = Date()
    @State private var selectedPlanet: Planet?

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = max(0, timeline.date.timeIntervalSince(startDate))

            RealityView { content in
                let root = Entity()
                root.name = "solar-system"
                content.add(root)

                if let sun = try? await fittedModel(
                    named: "Sun",
                    targetDiameter: 0.085
                ) {
                    sun.position.y = 0.0425
                    root.addChild(sun)
                }

                for (index, planet) in Planet.all.enumerated() {
                    if let model = try? await fittedModel(
                        named: planet.assetName,
                        targetDiameter: planet.size
                    ) {
                        model.name = planet.id
                        model.position = position(
                            for: planet,
                            index: index,
                            elapsed: elapsed
                        )
                        model.components.set(InputTargetComponent())
                        model.components.set(HoverEffectComponent())
                        model.components.set(
                            CollisionComponent(shapes: [
                                .generateSphere(radius: planet.size / 2)
                            ])
                        )
                        root.addChild(model)
                    }
                }
            } update: { content in
                guard let root = content.entities.first(where: {
                    $0.name == "solar-system"
                }) else { return }

                for (index, planet) in Planet.all.enumerated() {
                    guard let model = root.findEntity(named: planet.id) else {
                        continue
                    }

                    model.position = position(
                        for: planet,
                        index: index,
                        elapsed: elapsed
                    )
                    model.orientation = simd_quatf(
                        angle: Float(elapsed * 0.8),
                        axis: SIMD3(0, 1, 0)
                    )
                    model.scale = SIMD3(
                        repeating: selectedPlanet?.id == planet.id ? 1.15 : 1
                    )
                }
            }
            .gesture(
                SpatialTapGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        guard let planet = planet(for: value.entity) else {
                            return
                        }

                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPlanet = planet
                        }
                    }
            )
        }
    }

    private func position(
        for planet: Planet,
        index: Int,
        elapsed: TimeInterval
    ) -> SIMD3<Float> {
        let progress = elapsed
            .truncatingRemainder(dividingBy: planet.orbitDuration)
            / planet.orbitDuration
        let angle = Float(progress * 2 * Double.pi)
            + Float(index) * Float.pi / 4
        let depth = sin(angle) * planet.orbitRadius

        return SIMD3(
            cos(angle) * planet.orbitRadius,
            planet.size / 2 - depth * sin(tilt),
            depth * cos(tilt)
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

    private func planet(for entity: Entity) -> Planet? {
        var candidate: Entity? = entity

        while let current = candidate {
            if let planet = Planet.all.first(where: {
                $0.id == current.name
            }) {
                return planet
            }
            candidate = current.parent
        }

        return nil
    }
}
