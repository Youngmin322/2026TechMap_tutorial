import SwiftUI
import RealityKit

struct SolarSystemAtlasView: View {
    var body: some View {
        RealityView { content in
            let root = Entity()
            root.name = "solar-system"
            content.add(root)
        }
    }
}
