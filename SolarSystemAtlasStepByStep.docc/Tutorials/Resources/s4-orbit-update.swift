import SwiftUI
import RealityKit

struct SolarSystemScene: View {
    @State private var animationStartDate = Date()
    @State private var selectedPlanet: Planet?

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = max(
                0,
                timeline.date.timeIntervalSince(animationStartDate)
            )

            RealityView { content in
                let root = Entity()
                root.name = "solar-system-root"
                content.add(root)

                // 이곳에서 태양, 궤도, 행성을 한 번만 추가합니다.
            } update: { content in
                guard let root = content.entities.first(where: {
                    $0.name == "solar-system-root"
                }) else {
                    return
                }

                for (index, planet) in Planet.starter.enumerated() {
                    update(
                        planet,
                        index: index,
                        in: root,
                        elapsedTime: elapsedTime
                    )
                }
            }
        }
    }

    private func update(
        _ planet: Planet,
        index: Int,
        in root: Entity,
        elapsedTime: TimeInterval
    ) {
        let orbitProgress = cycleProgress(
            elapsedTime,
            duration: planet.orbitDuration
        )
        let orbitAngle = Double(index) * .pi / 4
            + orbitProgress * 2 * .pi
        let spinProgress = cycleProgress(
            elapsedTime,
            duration: planet.rotationDuration
        )
        let spinAngle = spinProgress * 2 * .pi
            * planet.rotationDirection

        guard let model = root.findEntity(
            named: "model-\(planet.id)"
        ) else {
            return
        }

        model.position = planetPosition(
            planet,
            angle: Float(orbitAngle)
        )
        model.orientation = simd_quatf(
            angle: Float(spinAngle),
            axis: SIMD3(0, 1, 0)
        )
    }

    private func cycleProgress(
        _ elapsedTime: TimeInterval,
        duration: TimeInterval
    ) -> Double {
        elapsedTime.truncatingRemainder(dividingBy: duration) / duration
    }
}
