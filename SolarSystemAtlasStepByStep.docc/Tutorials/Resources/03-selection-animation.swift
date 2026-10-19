import SwiftUI

struct SolarSystemView: View {
    @State private var selectedPlanet: Planet?

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate

            // 태양과 행성의 중심을 같은 3D 공간에 놓습니다.
            SpatialContainer(alignment: .center) {
                PlanetModelView(assetName: "Sun")

                ForEach(Planet.starter) { planet in
                    PlanetOrbitView(
                        planet: planet,
                        time: now,
                        isSelected: selectedPlanet?.id == planet.id,
                        select: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPlanet = selectedPlanet?.id == planet.id
                                    ? nil
                                    : planet
                            }
                        }
                    )
                }
            }
            .frame(width: 800, height: 380)
            .frame(depth: 620)
            .padding3D(24)
        }
    }
}
