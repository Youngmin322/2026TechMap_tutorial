import SwiftUI

struct ContentView: View {
    var body: some View {
        PlanetModelView(assetName: "Earth")
            .frame(width: 180, height: 180)
            .frame(depth: 180)
    }
}
