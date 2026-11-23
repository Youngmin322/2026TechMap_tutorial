import SwiftUI

struct PlanetEntryView: View {
    let planet: Planet

    var body: some View {
        VStack(spacing: 12) {
            PlanetModelView(planet: planet)

            Text(planet.name)
                .font(.headline)

            Text(planet.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 150, height: 190)
    }
}
