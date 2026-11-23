import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 24) {
                ForEach(Planet.starter) { planet in
                    PlanetEntryView(planet: planet)
                }
            }
            .padding(32)
        }
    }
}
