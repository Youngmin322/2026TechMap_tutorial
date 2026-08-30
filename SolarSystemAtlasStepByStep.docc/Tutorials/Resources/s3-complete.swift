import SwiftUI
import RealityKit
import RealityKitContent

struct Planet: Identifiable, Hashable {
    let name: String
    let assetName: String
    let summary: String
    let depth: CGFloat
    let orbitRadius: CGFloat
    let orbitDuration: TimeInterval
    let rotationDuration: TimeInterval
    let rotationDirection: Double

    var id: String { assetName }

    static let starter: [Planet] = [
        .init(name: "수성", assetName: "Mercury", summary: "태양에 가장 가까운 암석 행성", depth: -56, orbitRadius: 72, orbitDuration: 12, rotationDuration: 3, rotationDirection: 1),
        .init(name: "금성", assetName: "Venus", summary: "두꺼운 대기를 가진 암석 행성", depth: -18, orbitRadius: 112, orbitDuration: 18, rotationDuration: 4, rotationDirection: -1),
        .init(name: "지구", assetName: "Earth", summary: "액체 상태의 바다가 있는 행성", depth: 24, orbitRadius: 156, orbitDuration: 24, rotationDuration: 3.5, rotationDirection: 1),
        .init(name: "화성", assetName: "Mars", summary: "산화철 때문에 붉게 보이는 행성", depth: 62, orbitRadius: 204, orbitDuration: 32, rotationDuration: 4.2, rotationDirection: 1)
    ]
}

struct SolarSystemView: View {
    @State private var selectedPlanet: Planet?

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate

            // 여러 3D 자식을 같은 공간 좌표계에서 정렬합니다.
            SpatialContainer(alignment: .center) {
                HStackLayout(spacing: 24).depthAlignment(.center) {
                    ForEach(Planet.starter) { planet in
                        SelectablePlanetView(
                            planet: planet,
                            time: now,
                            isSelected: selectedPlanet?.id == planet.id
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPlanet = selectedPlanet?.id == planet.id ? nil : planet
                            }
                        }
                    }
                }
                .padding3D(48)
            }
        }
    }
}

private struct SelectablePlanetView: View {
    let planet: Planet
    let time: TimeInterval
    let isSelected: Bool
    let select: () -> Void

    private var orbitAngle: Angle {
        .degrees(time.truncatingRemainder(dividingBy: planet.orbitDuration) / planet.orbitDuration * 360)
    }

    private var spinAngle: Angle {
        .degrees(time.truncatingRemainder(dividingBy: planet.rotationDuration) / planet.rotationDuration * 360 * planet.rotationDirection)
    }

    var body: some View {
        PlanetModelView(assetName: planet.assetName)
            .frame(width: isSelected ? 102 : 84, height: isSelected ? 102 : 84)
            .offset(z: planet.depth)
            .offset(x: planet.orbitRadius)
            .rotation3DLayout(orbitAngle, axis: .y)
            .rotation3DLayout(spinAngle, axis: .y)
            .hoverEffect()
            .onTapGesture(perform: select)
            // 카드의 좌표는 화면 전체가 아니라 선택한 모델의 3D 경계입니다.
            .spatialOverlay(alignment: .bottomFront) {
                if isSelected {
                    PlanetInfoCard(planet: planet, dismiss: select)
                        .offset(z: 12)
                }
            }
    }
}

private struct PlanetInfoCard: View {
    let planet: Planet
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(planet.name)
                    .font(.headline)
                Spacer()
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain)
            }
            Text(planet.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 190, alignment: .leading)
        .padding()
        .glassBackgroundEffect()
    }
}

private struct PlanetModelView: View {
    let assetName: String

    var body: some View {
        Model3D(named: assetName, bundle: realityKitContentBundle) { phase in
            if let model = phase.model {
                model.resizable().aspectRatio(contentMode: .fit)
            } else if phase.error != nil {
                ContentUnavailableView("모델을 불러올 수 없습니다", systemImage: "exclamationmark.triangle")
            } else {
                ProgressView()
            }
        }
    }
}
