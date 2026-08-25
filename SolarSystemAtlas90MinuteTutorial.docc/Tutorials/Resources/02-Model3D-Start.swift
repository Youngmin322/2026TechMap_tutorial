import SwiftUI
import RealityKit
import RealityKitContent

struct PlanetModelView: View {
    let planet: Planet
    var size: Double = 90

    var body: some View {
        Model3D(
            named: planet.assetName,
            bundle: realityKitContentBundle
        ) { phase in
            if let model = phase.model {
                model
                    .resizable()
                    .scaledToFit3D()
            } else {
                ProgressView()
            }
        }
        .frame(width: size, height: size)
        .frame(depth: size)
    }
}
