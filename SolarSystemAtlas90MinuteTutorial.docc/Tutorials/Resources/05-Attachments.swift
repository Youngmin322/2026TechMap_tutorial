import SwiftUI
import RealityKit

struct PlanetLabelScene: View {
    var body: some View {
        RealityView { content, attachments in
            // 다음 단계에서 attachment 엔티티를 장면에 연결합니다.
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
    }
}
