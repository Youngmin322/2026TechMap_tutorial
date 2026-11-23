import SwiftUI
import RealityKit
import RealityKitContent

struct SolarSystemAtlasView: View {
    var body: some View {
        RealityView { content in
            let root = Entity()
            root.name = "solar-system-root"
            content.add(root)
        }
    }
}
