//
//  PlanetEntryView.swift
//  SolarSystemAtlas
//
//  Created by Youngmin Cho on 8/13/26.
//

import SwiftUI

struct PlanetEntryView: View {
    let planet: Planet

    var body: some View {
        VStack(spacing: 12) {
            PlanetModelView(planet: planet)
            PlanetInfoCard(planet: planet)
        }
        .frame(width: 150, height: 190)
    }
}
