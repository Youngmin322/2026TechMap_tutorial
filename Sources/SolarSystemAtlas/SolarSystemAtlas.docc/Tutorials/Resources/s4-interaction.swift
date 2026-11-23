import SwiftUI
import RealityKit

struct InteractiveSolarSystem: View {
    @State private var selectedPlanet: Planet?

    var body: some View {
        ZStack(alignment: .trailing) {
            RealityView { content, attachments in
                let root = Entity()
                root.name = "solar-system-root"
                content.add(root)

                // 행성 모델을 만든 뒤 같은 ID의 레이블을 연결합니다.
                for planet in Planet.starter {
                    if let label = attachments.entity(for: planet.id) {
                        label.name = "label-\(planet.id)"
                        root.addChild(label)
                    }
                }
            } update: { _, _ in
                // 선택한 모델의 scale을 이곳에서 갱신합니다.
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
            }
        }
    }

    private func planet(for entity: Entity) -> Planet? {
        var candidate: Entity? = entity

        while let current = candidate {
            if let planet = Planet.starter.first(where: {
                "model-\($0.id)" == current.name
            }) {
                return planet
            }

            candidate = current.parent
        }

        return nil
    }
}
