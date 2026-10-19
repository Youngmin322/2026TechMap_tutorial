import SwiftUI

@main
struct SolarSystemAtlasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.9, height: 0.5, depth: 0.9, in: .meters)
    }
}
