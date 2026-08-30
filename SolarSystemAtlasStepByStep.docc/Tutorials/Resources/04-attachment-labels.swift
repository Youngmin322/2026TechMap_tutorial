import SwiftUI
import RealityKit

struct PlanetLabels: View {
    var body: some View {
        RealityView { content, attachments in
            let root = Entity()
            root.name = "solar-system-root"
            content.add(root)

            for planet in Planet.starter {
                if let label = attachments.entity(for: planet.id) {
                    label.name = "label-\(planet.id)"
                    root.addChild(label)
                }
            }
        } attachments: {
            ForEach(Planet.starter) { planet in
                Attachment(id: planet.id) {
                    Text(planet.name)
                        .font(.caption2)
                        .padding(6)
                        .glassBackgroundEffect()
                }
            }
        }
    }
}
