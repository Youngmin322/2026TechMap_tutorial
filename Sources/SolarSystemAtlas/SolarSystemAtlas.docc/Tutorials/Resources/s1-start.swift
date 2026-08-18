import SwiftUI

@main
struct SolarSystemAtlasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 900, height: 500, depth: 700, in: .points)
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 72))
                .foregroundStyle(.yellow)

            Text("SolarSystemAtlas")
                .font(.largeTitle)

            Text("SwiftUI Spatial Layout을 학습할 준비가 되었습니다.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
