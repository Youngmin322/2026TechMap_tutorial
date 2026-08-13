//
//  SolarSystemAtlasView.swift
//  SolarSystemAtlas
//
//  Created by Youngmin Cho on 8/13/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct SolarSystemAtlasView: View {
    private let canvasSize: Double = 860
    private let sunSize: Double = 88

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                ForEach(Planet.starter) { planet in
                    Circle()
                        .stroke(.white.opacity(0.22), lineWidth: 1)
                        .frame(
                            width: planet.orbitRadius * 2,
                            height: planet.orbitRadius * 2
                        )
                }

                Model3D(
                    named: "Sun",
                    bundle: realityKitContentBundle
                ) { phase in
                    if let model = phase.model {
                        model
                            .resizable()
                            .scaledToFit3D()
                    } else if let error = phase.error {
                        Text("태양 로드 실패: \(error.localizedDescription)")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    } else {
                        ProgressView()
                            .accessibilityLabel("태양 불러오는 중")
                    }
                }
                .frame(width: sunSize, height: sunSize)
                .frame(depth: sunSize)

                ForEach(Array(Planet.starter.enumerated()), id: \.element.id) { index, planet in
                    OrbitingPlanetView(
                        planet: planet,
                        index: index,
                        elapsedTime: elapsedTime,
                        canvasSize: canvasSize
                    )
                }
            }
            .frame(width: canvasSize, height: canvasSize)
            .padding(32)
        }
    }
}

private struct OrbitingPlanetView: View {
    let planet: Planet
    let index: Int
    let elapsedTime: TimeInterval
    let canvasSize: Double

    private var orbitAngle: Double {
        let startOffset = Double(index) * .pi / 4
        return elapsedTime / planet.orbitDuration * 2 * .pi + startOffset
    }

    private var spinAngle: Angle {
        .degrees(elapsedTime / planet.rotationDuration * 360)
    }

    private var planetPosition: CGPoint {
        let center = canvasSize / 2
        return CGPoint(
            x: center + cos(orbitAngle) * planet.orbitRadius,
            y: center + sin(orbitAngle) * planet.orbitRadius
        )
    }

    var body: some View {
        VStack(spacing: 6) {
            PlanetModelView(
                planet: planet,
                size: planet.displaySize,
                spinAngle: spinAngle
            )

            Text(planet.name)
                .font(.caption2)
        }
        .frame(width: 86, height: 100)
        .position(planetPosition)
        .zIndex(planetPosition.y)
    }
}
