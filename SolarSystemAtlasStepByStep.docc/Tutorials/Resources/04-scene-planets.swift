import SwiftUI
import RealityKit

struct SolarSystemScene: View {
    private let sunDiameter: Float = 0.088
    private let sunRotationDuration: TimeInterval = 8

    @State private var isLoading = true
    @State private var loadErrors: [String] = []

    var body: some View {
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
                isLoading = false
            } attachments: {
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
        model.position = OrbitPosition.planetPosition(
            radius: radius,
            diameter: diameter,
            angle: startAngle
        )
        root.addChild(model)

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
