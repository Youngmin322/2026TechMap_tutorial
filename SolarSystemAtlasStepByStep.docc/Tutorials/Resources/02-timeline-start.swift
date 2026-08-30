import SwiftUI

struct PlanetOrbitView: View {
    let planet: Planet
    let time: TimeInterval

    var body: some View {
        PlanetModelView(assetName: planet.assetName)
    }
}
