//
//  PlanetInfoCard.swift
//  SolarSystemAtlas
//
//  Created by Youngmin Cho on 8/13/26.
//

import SwiftUI

struct PlanetInfoCard: View {
    let planet: Planet

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(planet.name)
                .font(.headline)

            Text(planet.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(12)
        .frame(width: 150, alignment: .leading)
        .glassBackgroundEffect()
    }
}
