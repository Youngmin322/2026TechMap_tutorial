import SwiftUI

struct SolarSystemView: View {
    var body: some View {
        HStackLayout(spacing: 12).depthAlignment(.center) {
            PlanetModelView(assetName: "Sun")
                .frame(width: 96, height: 96)

            ForEach(Planet.starter) { planet in
                PlanetModelView(assetName: planet.assetName)
                    .frame(width: 68, height: 68)
                    .offset(z: planet.depth)
            }
        }
        .padding3D(32)
    }
}
