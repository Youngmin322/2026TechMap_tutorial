import SwiftUI
import RealityKit

struct PlanetSelection<Scene: View>: View {
    let scene: Scene
    @State private var selectedPlanet: Planet?

    var body: some View {
        ZStack(alignment: .trailing) {
            scene
                .gesture(
                    SpatialTapGesture()
                        .targetedToAnyEntity()
                        .onEnded { value in
                            guard let planet = planet(
                                for: value.entity
                            ) else {
                                return
                            }

                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPlanet = planet
                            }
                        }
                )

            if let selectedPlanet {
                PlanetInfoCard(planet: selectedPlanet) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.selectedPlanet = nil
                    }
                }
                .padding(28)
            }
        }
    }
}
