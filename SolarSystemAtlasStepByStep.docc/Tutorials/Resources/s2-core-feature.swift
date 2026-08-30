import SwiftUI
import RealityKit
import RealityKitContent

struct Planet: Identifiable, Hashable {
    let name: String
    let assetName: String
    let depth: CGFloat
    let orbitRadius: CGFloat
    let orbitDuration: TimeInterval
    let rotationDuration: TimeInterval
    let rotationDirection: Double

    var id: String { assetName }

    static let starter: [Planet] = [
        .init(name: "수성", assetName: "Mercury", depth: -56, orbitRadius: 72, orbitDuration: 12, rotationDuration: 3, rotationDirection: 1),
        .init(name: "금성", assetName: "Venus", depth: -18, orbitRadius: 112, orbitDuration: 18, rotationDuration: 4, rotationDirection: -1),
        .init(name: "지구", assetName: "Earth", depth: 24, orbitRadius: 156, orbitDuration: 24, rotationDuration: 3.5, rotationDirection: 1),
        .init(name: "화성", assetName: "Mars", depth: 62, orbitRadius: 204, orbitDuration: 32, rotationDuration: 4.2, rotationDirection: 1)
    ]
}

struct SolarSystemView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate

            // Layout 자체에 깊이 기준면을 제공합니다.
            HStackLayout(spacing: 24).depthAlignment(.center) {
                ForEach(Planet.starter) { planet in
                    PlanetOrbitView(planet: planet, time: now)
                }
            }
            .padding3D(48)
        }
    }
}

private struct PlanetOrbitView: View {
    let planet: Planet
    let time: TimeInterval

    private var orbitAngle: Angle {
        .degrees(time.truncatingRemainder(dividingBy: planet.orbitDuration) / planet.orbitDuration * 360)
    }

    private var spinAngle: Angle {
        .degrees(time.truncatingRemainder(dividingBy: planet.rotationDuration) / planet.rotationDuration * 360 * planet.rotationDirection)
    }

    var body: some View {
        PlanetModelView(assetName: planet.assetName)
            .frame(width: 84, height: 84)
            // 기준면에서의 앞뒤 거리입니다.
            .offset(z: planet.depth)
            // 반지름만큼 이동한 뷰를 돌려 공전 경로를 만듭니다.
            .offset(x: planet.orbitRadius)
            .rotation3DLayout(orbitAngle, axis: .y)
            // 행성 자체는 별도의 각도로 자전합니다.
            .rotation3DLayout(spinAngle, axis: .y)
    }
}

private struct PlanetModelView: View {
    let assetName: String

    var body: some View {
        Model3D(named: assetName, bundle: realityKitContentBundle) { phase in
            if let model = phase.model {
                model
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if phase.error != nil {
                ContentUnavailableView("모델을 불러올 수 없습니다", systemImage: "exclamationmark.triangle")
            } else {
                ProgressView()
            }
        }
    }
}
