import SwiftUI

struct PlanetInfoCard: View {
    let planet: Planet
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(planet.name)
                    .font(.headline)

                Spacer()

                Button("닫기", action: dismiss)
            }

            Text(planet.summary)
                .font(.caption)
        }
    }
}
