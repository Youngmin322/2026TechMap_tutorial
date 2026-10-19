import Foundation

struct Planet: Identifiable, Hashable {
    let name: String
    let assetName: String
    let summary: String
    let displaySize: CGFloat
    let depth: CGFloat
    let orbitRadius: CGFloat
    let orbitDuration: TimeInterval
    let rotationDuration: TimeInterval
    let rotationDirection: Double

    var id: String { assetName }

    static let starter: [Planet] = [
        .init(name: "수성", assetName: "Mercury", summary: "태양에 가장 가까운 행성", displaySize: 42, depth: -70, orbitRadius: 92, orbitDuration: 8, rotationDuration: 2.4, rotationDirection: 1),
        .init(name: "금성", assetName: "Venus", summary: "두꺼운 대기를 가진 암석 행성", displaySize: 48, depth: -50, orbitRadius: 130, orbitDuration: 12, rotationDuration: 3.8, rotationDirection: -1),
        .init(name: "지구", assetName: "Earth", summary: "액체 상태의 바다가 있는 행성", displaySize: 50, depth: -30, orbitRadius: 168, orbitDuration: 16, rotationDuration: 2.8, rotationDirection: 1),
        .init(name: "화성", assetName: "Mars", summary: "산화철 때문에 붉게 보이는 행성", displaySize: 46, depth: -10, orbitRadius: 206, orbitDuration: 20, rotationDuration: 3, rotationDirection: 1),
        .init(name: "목성", assetName: "Jupiter", summary: "태양계에서 가장 큰 가스 행성", displaySize: 74, depth: 10, orbitRadius: 252, orbitDuration: 25, rotationDuration: 2.2, rotationDirection: 1),
        .init(name: "토성", assetName: "Saturn", summary: "뚜렷한 고리로 알려진 가스 행성", displaySize: 72, depth: 30, orbitRadius: 296, orbitDuration: 30, rotationDuration: 2.5, rotationDirection: 1),
        .init(name: "천왕성", assetName: "Uranus", summary: "자전축이 크게 기울어진 얼음 행성", displaySize: 58, depth: 50, orbitRadius: 336, orbitDuration: 36, rotationDuration: 3.2, rotationDirection: -1),
        .init(name: "해왕성", assetName: "Neptune", summary: "빠른 바람이 부는 얼음 행성", displaySize: 58, depth: 70, orbitRadius: 374, orbitDuration: 42, rotationDuration: 3.1, rotationDirection: 1)
    ]
}


import SwiftUI

struct PlanetInfoCard: View {
    let planet: Planet
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(planet.name)
                    .font(.headline)

                Spacer()

                Button("닫기", action: dismiss)
                    .buttonStyle(.plain)
                    .accessibilityLabel("도감 닫기")
            }

            Text(planet.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 190, alignment: .leading)
        .padding()
        .glassBackgroundEffect()
    }
}


import RealityKit
import RealityKitContent

enum EntitySetup {
    static func fittedModel(
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


import Foundation
import RealityKit

enum OrbitPosition {
    static let pointToMeter: Float = 0.001
    static let tabletopTilt: Float = .pi / 10

    static func planetPosition(
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

    static func labelPosition(
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

    static func cycleProgress(
        _ elapsedTime: TimeInterval,
        duration: TimeInterval
    ) -> Double {
        elapsedTime.truncatingRemainder(dividingBy: duration) / duration
    }

    static func rotation(radians: Float) -> simd_quatf {
        simd_quatf(angle: radians, axis: SIMD3(0, 1, 0))
    }
}


import RealityKit
import UIKit

enum OrbitGuide {
    static func makeOrbitRing(radius: Float) throws -> ModelEntity {
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
}


import SwiftUI
import RealityKit

struct SolarSystemScene: View {
    private let sunDiameter: Float = 0.088
    private let sunRotationDuration: TimeInterval = 8

    @State private var isLoading = true
    @State private var loadErrors: [String] = []
    @State private var animationStartDate = Date()
    @State private var selectedPlanet: Planet?

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = max(0, timeline.date.timeIntervalSince(animationStartDate))

            ZStack(alignment: .trailing) {
                RealityView { content, attachments in
                    let root = Entity()
                    root.name = EntityName.root
                    content.add(root)
                    addOrbitPlate(to: root)
                    await addSun(to: root)
                    for (index, planet) in Planet.starter.enumerated() {
                        await addPlanet(planet, index: index, to: root, attachments: attachments)
                    }
                    animationStartDate = Date()
                    isLoading = false
                } update: { content, _ in
                    guard let root = content.entities.first(where: {
                        $0.name == EntityName.root
                    }) else { return }
                    updateSun(in: root, elapsedTime: elapsedTime)
                    for (index, planet) in Planet.starter.enumerated() {
                        update(planet, index: index, in: root, elapsedTime: elapsedTime, isSelected: selectedPlanet?.id == planet.id)
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
                            guard let planet = planet(for: value.entity) else { return }
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPlanet = selectedPlanet?.id == planet.id ? nil : planet
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
                if isLoading {
                    ProgressView("태양계 모델 불러오는 중")
                        .frame(maxWidth: .infinity)
                }
                if !loadErrors.isEmpty {
                    Text("불러오지 못한 모델: " + loadErrors.joined(separator: ", "))
                        .padding()
                        .glassBackgroundEffect()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
    }

    private func addOrbitPlate(to root: Entity) {
        let orbitPlate = Entity()
        orbitPlate.name = EntityName.orbitPlate
        orbitPlate.orientation = simd_quatf(
            angle: OrbitPosition.tabletopTilt,
            axis: SIMD3(1, 0, 0)
        )
        root.addChild(orbitPlate)

        for planet in Planet.starter {
            let radius = Float(planet.orbitRadius) * OrbitPosition.pointToMeter

            if let orbit = try? OrbitGuide.makeOrbitRing(radius: radius) {
                orbitPlate.addChild(orbit)
            }
        }
    }

    private func addSun(to root: Entity) async {
        do {
            let sun = try await EntitySetup.fittedModel(named: "Sun", targetDiameter: sunDiameter)
            sun.name = EntityName.sun
            sun.position.y = sunDiameter / 2
            root.addChild(sun)
        } catch {
            loadErrors.append("Sun")
        }
    }

    private func addPlanet(
        _ planet: Planet,
        index: Int,
        to root: Entity,
        attachments: RealityViewAttachments
    ) async {
        let model: Entity
        do {
            model = try await EntitySetup.fittedModel(
                named: planet.assetName,
                targetDiameter: Float(planet.displaySize) * OrbitPosition.pointToMeter
            )
        } catch {
            loadErrors.append(planet.assetName)
            return
        }

        let diameter = Float(planet.displaySize) * OrbitPosition.pointToMeter
        let radius = Float(planet.orbitRadius) * OrbitPosition.pointToMeter
        let startAngle = Float(Double(index) * .pi / 4)

        model.name = EntityName.model(planet)
        model.components.set(InputTargetComponent())
        model.components.set(
            CollisionComponent(
                shapes: [.generateSphere(radius: diameter / 2)]
            )
        )
        model.components.set(HoverEffectComponent())
        model.position = OrbitPosition.planetPosition(
            radius: radius,
            diameter: diameter,
            angle: startAngle
        )
        root.addChild(model)

        if let label = attachments.entity(for: planet.id) {
            label.name = EntityName.label(planet)
            label.position = OrbitPosition.labelPosition(
                radius: radius,
                diameter: diameter,
                angle: startAngle
            )
            root.addChild(label)
        }
    }

    private func updateSun(in root: Entity, elapsedTime: TimeInterval) {
        let progress = OrbitPosition.cycleProgress(
            elapsedTime,
            duration: sunRotationDuration
        )
        root.findEntity(named: EntityName.sun)?.orientation = OrbitPosition.rotation(
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
        let orbitProgress = OrbitPosition.cycleProgress(
            elapsedTime,
            duration: planet.orbitDuration
        )
        let startOffset = Double(index) * .pi / 4
        let orbitAngle = startOffset + orbitProgress * 2 * .pi

        let spinProgress = OrbitPosition.cycleProgress(
            elapsedTime,
            duration: planet.rotationDuration
        )
        let spinAngle = spinProgress * 2 * .pi * planet.rotationDirection
        let radius = Float(planet.orbitRadius) * OrbitPosition.pointToMeter
        let diameter = Float(planet.displaySize) * OrbitPosition.pointToMeter
        let angle = Float(orbitAngle)

        if let model = root.findEntity(named: EntityName.model(planet)) {
            model.position = OrbitPosition.planetPosition(
                radius: radius,
                diameter: diameter,
                angle: angle
            )
            model.orientation = OrbitPosition.rotation(radians: Float(spinAngle))
            model.scale = SIMD3(repeating: isSelected ? 1.18 : 1)
        }

        root.findEntity(named: EntityName.label(planet))?.position = OrbitPosition.labelPosition(
            radius: radius,
            diameter: diameter,
            angle: angle
        )
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
