import SwiftUI

struct SolarSystemView: View {
    var body: some View {
        HStack(spacing: 12) {
            PlanetModelView(assetName: "Sun")
                .frame(width: 96, height: 96)

            ForEach(Planet.starter) { planet in
                PlanetModelView(assetName: planet.assetName)
                    .frame(width: 68, height: 68)
            }
        }
        .padding3D(32)
    }
}
