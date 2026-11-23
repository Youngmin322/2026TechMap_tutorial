//
//  SolarSystemAtlasView.swift
//  SolarSystemAtlas
//
//  Created by Youngmin Cho on 8/13/26.
//

import SwiftUI
import RealityKit
import RealityKitContent
import UIKit

struct SolarSystemAtlasView: View {
    private let pointToMeter: Float = 0.001
    private let sunDiameter: Float = 0.088
    private let sunRotationDuration: TimeInterval = 8
    private let tabletopTilt: Float = .pi / 10

    @State private var animationStartDate = Date()
    @State private var selectedPlanet: Planet?

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = max(
                0,
                timeline.date.timeIntervalSince(animationStartDate)
            )

            ZStack(alignment: .trailing) {
                RealityView { content, attachments in
                    let root = Entity()
                    root.name = EntityName.root
                    content.add(root)

                    addOrbitPlate(to: root)
                    await addSun(to: root)

                    for (index, planet) in Planet.starter.enumerated() {
                        await addPlanet(
                            planet,
                            index: index,
                            to: root,
                            attachments: attachments
                        )
                    }
                } update: { content, _ in
                    guard let root = content.entities.first(where: {
                        $0.name == EntityName.root
                    }) else {
                        return
                    }

                    updateSun(in: root, elapsedTime: elapsedTime)

                    for (index, planet) in Planet.starter.enumerated() {
                        update(
                            planet,
                            index: index,
                            in: root,
                            elapsedTime: elapsedTime,
                            isSelected: selectedPlanet?.id == planet.id
                        )
                    }
                } attachments: {
                    ForEach(Planet.starter) { planet in
                        Attachment(id: planet.id) {
                            Text(planet.name)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .glassBackgroundEffect()
                        }
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

                if let selectedPlanet {
                    PlanetInfoCard(planet: selectedPlanet) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.selectedPlanet = nil
                        }
                    }
                    .padding(28)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
        }
    }

    private func addOrbitPlate(to root: Entity) {
        let orbitPlate = Entity()
        orbitPlate.name = EntityName.orbitPlate
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

    private func addSun(to root: Entity) async {
        guard let sun = try? await fittedModel(
            named: "Sun",
            targetDiameter: sunDiameter
        ) else {
            return
        }

        sun.name = EntityName.sun
        sun.position.y = sunDiameter / 2
        root.addChild(sun)
    }

    private func addPlanet(
        _ planet: Planet,
        index: Int,
        to root: Entity,
        attachments: RealityViewAttachments
    ) async {
        guard let model = try? await fittedModel(
            named: planet.assetName,
            targetDiameter: Float(planet.displaySize) * pointToMeter
        ) else {
            return
        }

        let diameter = Float(planet.displaySize) * pointToMeter
        let radius = Float(planet.orbitRadius) * pointToMeter
        let startAngle = Float(Double(index) * .pi / 4)

        model.name = EntityName.model(planet)
        model.components.set(InputTargetComponent())
        model.components.set(
            CollisionComponent(
                shapes: [.generateSphere(radius: diameter / 2)]
            )
        )
        model.components.set(HoverEffectComponent())
        model.position = planetPosition(
            radius: radius,
            diameter: diameter,
            angle: startAngle
        )
        root.addChild(model)

        if let label = attachments.entity(for: planet.id) {
            label.name = EntityName.label(planet)
            label.position = labelPosition(
                radius: radius,
                diameter: diameter,
                angle: startAngle
            )
            root.addChild(label)
        }
    }

    private func updateSun(in root: Entity, elapsedTime: TimeInterval) {
        let progress = cycleProgress(
            elapsedTime,
            duration: sunRotationDuration
        )
        root.findEntity(named: EntityName.sun)?.orientation = rotation(
            radians: Float(progress * 2 * .pi)
        )
    }

    private func update(
        _ planet: Planet,
        index: Int,
        in root: Entity,
        elapsedTime: TimeInterval,
        isSelected: Bool
    ) {
        let orbitProgress = cycleProgress(
            elapsedTime,
            duration: planet.orbitDuration
        )
        let startOffset = Double(index) * .pi / 4
        let orbitAngle = startOffset + orbitProgress * 2 * .pi

        let spinProgress = cycleProgress(
            elapsedTime,
            duration: planet.rotationDuration
        )
        let spinAngle = spinProgress * 2 * .pi * planet.rotationDirection
        let radius = Float(planet.orbitRadius) * pointToMeter
        let diameter = Float(planet.displaySize) * pointToMeter
        let angle = Float(orbitAngle)

        if let model = root.findEntity(named: EntityName.model(planet)) {
            model.position = planetPosition(
                radius: radius,
                diameter: diameter,
                angle: angle
            )
            model.orientation = rotation(radians: Float(spinAngle))
            model.scale = SIMD3(repeating: isSelected ? 1.18 : 1)
        }

        root.findEntity(named: EntityName.label(planet))?.position = labelPosition(
            radius: radius,
            diameter: diameter,
            angle: angle
        )
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

    private func labelPosition(
        radius: Float,
        diameter: Float,
        angle: Float
    ) -> SIMD3<Float> {
        var position = planetPosition(
            radius: radius,
            diameter: diameter,
            angle: angle
        )
        position.y += diameter / 2 + 0.018
        return position
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

    private func makeOrbitRing(radius: Float) throws -> ModelEntity {
        let segments = 192
        let halfWidth: Float = 0.00075
        var positions: [SIMD3<Float>] = []
        var indices: [UInt32] = []

        positions.reserveCapacity((segments + 1) * 2)
        indices.reserveCapacity(segments * 6)

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
        let color = UIColor.white.withAlphaComponent(0.28)
        var material = UnlitMaterial(color: color)
        material.faceCulling = .none
        return ModelEntity(mesh: mesh, materials: [material])
    }

    private func cycleProgress(
        _ elapsedTime: TimeInterval,
        duration: TimeInterval
    ) -> Double {
        elapsedTime.truncatingRemainder(dividingBy: duration) / duration
    }

    private func rotation(radians: Float) -> simd_quatf {
        simd_quatf(angle: radians, axis: SIMD3(0, 1, 0))
    }

    private func planet(for entity: Entity) -> Planet? {
        var candidate: Entity? = entity

        while let current = candidate {
            if let planet = Planet.starter.first(where: {
                EntityName.model($0) == current.name
            }) {
                return planet
            }

            candidate = current.parent
        }

        return nil
    }
}

private enum EntityName {
    static let root = "solar-system-root"
    static let sun = "sun-model"
    static let orbitPlate = "orbit-plate"

    static func model(_ planet: Planet) -> String {
        "model-\(planet.id)"
    }

    static func label(_ planet: Planet) -> String {
        "label-\(planet.id)"
    }
}
