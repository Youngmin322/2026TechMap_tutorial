import SwiftUI

struct PlanetOrbitView: View {
    let planet: Planet
    let time: TimeInterval
    var isSelected: Bool = false
    var select: () -> Void = { }

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
            .scaleEffect(isSelected ? 1.12 : 1)
            .hoverEffect()
            .onTapGesture(perform: select)
            .spatialOverlay(alignment: .bottomFront) {
                if isSelected {
                    PlanetInfoCard(planet: planet, dismiss: select)
                        .offset(z: 12)
                }
            }
            // 카드도 같은 위치로 이동하도록 자전·오버레이 뒤에 적용합니다.
            .offset(x: orbitX, y: -orbitDepth * 0.3)
            .offset(z: planet.depth + orbitDepth * 0.6)
    }
}
