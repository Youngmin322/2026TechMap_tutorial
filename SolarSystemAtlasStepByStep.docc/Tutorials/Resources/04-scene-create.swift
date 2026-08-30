import SwiftUI
import RealityKit

struct SolarSystemScene: View {
    var body: some View {
        RealityView { content in
            let root = Entity()
            root.name = "solar-system-root"
            content.add(root)

            await addSun(to: root)

            for planet in Planet.starter {
                await addPlanet(planet, to: root)
            }
        }
    }
}
