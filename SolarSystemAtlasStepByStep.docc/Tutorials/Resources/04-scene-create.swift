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
                await addSun(to: root)
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
