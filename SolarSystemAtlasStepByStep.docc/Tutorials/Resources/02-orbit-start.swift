import SwiftUI

struct PlanetOrbitView: View {
    let planet: Planet
    let time: TimeInterval

    private var orbitAngle: Angle {
        let progress = time.truncatingRemainder(
            dividingBy: planet.orbitDuration
        ) / planet.orbitDuration
        return .degrees(progress * 360)
    }

    private var spinAngle: Angle {
        let progress = time.truncatingRemainder(
            dividingBy: planet.rotationDuration
        ) / planet.rotationDuration
        return .degrees(progress * 360 * planet.rotationDirection)
    }

    var body: some View {
        PlanetModelView(assetName: planet.assetName)
    }
}
