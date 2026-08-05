//
//  ContentView.swift
//  SolarSystemAtlas
//
//  Created by Youngmin Cho on 8/5/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    var body: some View {
        Model3D(
            named: "Earth",
            bundle: realityKitContentBundle
        ) { phase in
            if let model = phase.model {
                model
                    .resizable()
                    .scaledToFit3D()
            } else if let error = phase.error {
                Text("지구 로드 실패: \(error.localizedDescription)")
            } else {
                ProgressView()
            }
        }
    }
}

