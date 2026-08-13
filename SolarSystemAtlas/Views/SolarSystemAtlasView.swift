//
//  SolarSystemAtlasView.swift
//  SolarSystemAtlas
//
//  Created by Youngmin Cho on 8/13/26.
//

import SwiftUI

struct SolarSystemAtlasView: View {
    var body: some View {
        HStack(spacing: 24) {
            ForEach(Planet.starter) { planet in
                PlanetEntryView(planet: planet)
            }
        }
        .padding(32)
    }
}
