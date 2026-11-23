//
//  PlanetInfoCard.swift
//  SolarSystemAtlas
//
//  Created by Youngmin Cho on 8/13/26.
//

import SwiftUI

struct PlanetInfoCard: View {
    let planet: Planet
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let onDismiss {
                HStack {
                    Text("태양계 도감")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.caption.bold())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("도감 닫기")
                }
            }

            Text(planet.name)
                .font(onDismiss == nil ? .headline : .title2.bold())

            Text(planet.summary)
                .font(onDismiss == nil ? .caption : .body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(onDismiss == nil ? 12 : 18)
        .frame(
            width: onDismiss == nil ? 150 : 240,
            alignment: .leading
        )
        .glassBackgroundEffect()
    }
}
