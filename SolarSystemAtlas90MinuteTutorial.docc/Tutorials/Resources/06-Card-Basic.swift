import SwiftUI

struct PlanetInfoCard: View {
    let planet: Planet
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("태양계 도감")
                    .font(.caption)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                }
            }

            Text(planet.name)
                .font(.title2.bold())

            Text(planet.summary)
        }
        .padding(18)
        .frame(width: 240, alignment: .leading)
    }
}
