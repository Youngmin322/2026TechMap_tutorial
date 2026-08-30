import SwiftUI

@main
struct SolarSystemAtlasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(
            width: 900,
            height: 500,
            depth: 700,
            in: .points
        )
    }
}
