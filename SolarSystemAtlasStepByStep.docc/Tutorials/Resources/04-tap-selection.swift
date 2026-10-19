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
