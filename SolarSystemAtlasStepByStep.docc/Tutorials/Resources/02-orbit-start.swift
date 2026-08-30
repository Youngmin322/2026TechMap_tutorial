import SwiftUI

struct PlanetOrbitView: View {
    let planet: Planet
    let orbitAngle: Angle
    let spinAngle: Angle

    var body: some View {
        PlanetModelView(assetName: planet.assetName)
            .frame(width: 84, height: 84)
            .offset(z: planet.depth)
    }
}
