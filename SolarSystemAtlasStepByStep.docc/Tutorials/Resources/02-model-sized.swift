import SwiftUI
import RealityKit
import RealityKitContent

struct PlanetModelView: View {
    let assetName: String

    var body: some View {
        Model3D(
            named: assetName,
            bundle: realityKitContentBundle
        ) { phase in
            if let model = phase.model {
                model
                    .resizable()
                    .scaledToFit3D()
            } else if phase.error != nil {
                Text("\(assetName) 모델을 불러올 수 없습니다")
            } else {
                ProgressView()
            }
        }
        .frame(width: 84, height: 84)
        .frame(depth: 84)
    }
}
