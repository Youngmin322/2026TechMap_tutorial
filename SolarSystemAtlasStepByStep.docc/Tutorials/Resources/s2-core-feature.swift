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
        .init(name: "수성", assetName: "Mercury", depth: -70, orbitRadius: 56, orbitDuration: 8, rotationDuration: 2.4, rotationDirection: 1),
        .init(name: "금성", assetName: "Venus", depth: -50, orbitRadius: 84, orbitDuration: 12, rotationDuration: 3.8, rotationDirection: -1),
        .init(name: "지구", assetName: "Earth", depth: -30, orbitRadius: 112, orbitDuration: 16, rotationDuration: 2.8, rotationDirection: 1),
        .init(name: "화성", assetName: "Mars", depth: -10, orbitRadius: 140, orbitDuration: 20, rotationDuration: 3, rotationDirection: 1),
        .init(name: "목성", assetName: "Jupiter", depth: 10, orbitRadius: 172, orbitDuration: 25, rotationDuration: 2.2, rotationDirection: 1),
        .init(name: "토성", assetName: "Saturn", depth: 30, orbitRadius: 204, orbitDuration: 30, rotationDuration: 2.5, rotationDirection: 1),
        .init(name: "천왕성", assetName: "Uranus", depth: 50, orbitRadius: 236, orbitDuration: 36, rotationDuration: 3.2, rotationDirection: -1),
        .init(name: "해왕성", assetName: "Neptune", depth: 70, orbitRadius: 268, orbitDuration: 42, rotationDuration: 3.1, rotationDirection: 1)
    ]
}

struct SolarSystemView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate

            // 태양과 행성의 중심을 같은 3D 공간에 놓습니다.
            SpatialContainer(alignment: .center) {
                PlanetModelView(assetName: "Sun")

                ForEach(Planet.starter) { planet in
                    PlanetOrbitView(
                        planet: planet,
                        time: now
                    )
                }
            }
            .frame(width: 800, height: 380)
            .frame(depth: 620)
            .padding3D(24)
        }
    }
}

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

struct PlanetModelView: View {
    let assetName: String

    var body: some View {
        Model3D(
            named: assetName,
            bundle: realityKitContentBundle
        ) { phase in
            if let model = phase.model {
                model
                    .resizable()
                    .scaledToFit3D()
            } else if phase.error != nil {
                Text("\(assetName) 모델을 불러올 수 없습니다")
            } else {
                ProgressView()
            }
        }
        .frame(width: 84, height: 84)
        .frame(depth: 84)
    }
}
