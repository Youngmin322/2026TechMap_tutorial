//
//  PlanetModelView.swift
//  SolarSystemAtlas
//
//  Created by Youngmin Cho on 8/13/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct PlanetModelView: View {
    let planet: Planet

    var body: some View {
        Model3D(
            named: planet.assetName,
            bundle: realityKitContentBundle
        ) { phase in
            if let model = phase.model {
                model
                    .resizable()
                    .scaledToFit3D()
            } else if let error = phase.error {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                    Text("\(planet.name) 로드 실패")
                    Text(error.localizedDescription)
                        .font(.caption2)
                        .lineLimit(2)
                }
                .foregroundStyle(.red)
            } else {
                ProgressView()
                    .accessibilityLabel("\(planet.name) 불러오는 중")
            }
        }
        .frame(width: 90, height: 90)
        .frame(depth: 90)
    }
}
