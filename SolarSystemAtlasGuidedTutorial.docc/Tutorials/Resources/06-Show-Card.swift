import SwiftUI

struct SolarSystemWithCard<Scene: View>: View {
    let scene: Scene
    @Binding var selectedPlanet: Planet?

    var body: some View {
        ZStack(alignment: .trailing) {
            scene

            if let selectedPlanet {
                PlanetInfoCard(planet: selectedPlanet) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.selectedPlanet = nil
                    }
                }
                .padding(28)
                .transition(
                    .opacity.combined(with: .move(edge: .trailing))
                )
            }
        }
    }
}
