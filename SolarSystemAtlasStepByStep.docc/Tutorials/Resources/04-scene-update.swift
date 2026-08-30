import SwiftUI
import RealityKit

struct SolarSystemScene: View {
    @State private var animationStartDate = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = max(
                0,
                timeline.date.timeIntervalSince(animationStartDate)
            )

            RealityView { content in
                let root = Entity()
                root.name = "solar-system-root"
                content.add(root)

                await addSun(to: root)

                for planet in Planet.starter {
                    await addPlanet(planet, to: root)
                }
            } update: { content in
                guard let root = content.entities.first(where: {
                    $0.name == "solar-system-root"
                }) else {
                    return
                }

                updateSun(in: root, elapsedTime: elapsedTime)

                for planet in Planet.starter {
                    update(planet, in: root, elapsedTime: elapsedTime)
                }
            }
        }
    }
}
