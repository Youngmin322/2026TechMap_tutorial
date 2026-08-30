import SwiftUI

struct SolarSystemView: View {
    var body: some View {
        ForEach(Planet.starter) { planet in
            SelectablePlanetView(
                planet: planet,
                isSelected: false,
                select: { }
            )
        }
    }
}
