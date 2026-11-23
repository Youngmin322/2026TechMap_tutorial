import SwiftUI
import RealityKit

struct SelectableScene<Scene: View>: View {
    let scene: Scene
    @State private var selectedPlanet: Planet?

    var body: some View {
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
    }
}
