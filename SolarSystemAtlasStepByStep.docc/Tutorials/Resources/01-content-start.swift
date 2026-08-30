import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 72))
                .foregroundStyle(.yellow)

            Text("SolarSystemAtlas")
                .font(.largeTitle)

            Text("태양계를 불러올 준비가 되었습니다.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
