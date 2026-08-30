import SwiftUI

struct SolarSystemView: View {
    @State private var selectedPlanet: Planet?

    var body: some View {
        ForEach(Planet.starter) { planet in
            SelectablePlanetView(
                planet: planet,
                isSelected: selectedPlanet?.id == planet.id,
                select: {
                    selectedPlanet = selectedPlanet?.id == planet.id
                        ? nil
                        : planet
                }
            )
        }
    }
}
