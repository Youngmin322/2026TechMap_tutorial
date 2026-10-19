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

    private var orbitX: CGFloat {
        CGFloat(cos(orbitAngle.radians)) * planet.orbitRadius
    }

    private var orbitDepth: CGFloat {
        CGFloat(sin(orbitAngle.radians)) * planet.orbitRadius
    }

    var body: some View {
        PlanetModelView(assetName: planet.assetName)
            // 자전은 모델에만 적용합니다.
            .rotation3DLayout(spinAngle, axis: .y)
            // 공전 위치는 자전과 분리하고, 앞 장의 z축 이동량을 더합니다.
            .offset(x: orbitX, y: -orbitDepth * 0.3)
            .offset(z: planet.depth + orbitDepth * 0.6)
    }
}
