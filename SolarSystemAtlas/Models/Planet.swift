//
//  Planet.swift
//  SolarSystemAtlas
//
//  Created by Youngmin Cho on 8/6/26.
//

import Foundation

// Identifiable: ForEach에서 각 Planet을 구분하기 위해 필요
// Hashable: Planet 값을 비교하거나 Set/Dictionary 등에 넣을 수 있게 함
struct Planet: Identifiable, Hashable {
    let name: String
    let assetName: String
    let summary: String
    let displaySize: Double
    let orbitRadius: Double
    let orbitDuration: Double
    let rotationDuration: Double
    
    // SwiftUI의 ForEach가 각 행성을 안정적으로 구분할 때 사용하는 고유 값
    // assetName은 RealityKit asset 이름이면서 행성마다 중복되지 않으므로 id로 사용
    var id: String { assetName }
    
    static let starter: [Planet] = [
        Planet(
            name: "수성",
            assetName: "Mercury",
            summary: "태양에 가장 가까운 행성",
            displaySize: 42,
            orbitRadius: 92,
            orbitDuration: 8,
            rotationDuration: 2.8
        ),
        Planet(
            name: "금성",
            assetName: "Venus",
            summary: "두꺼운 대기를 가진 암석 행성",
            displaySize: 48,
            orbitRadius: 130,
            orbitDuration: 12,
            rotationDuration: 4.2
        ),
        Planet(
            name: "지구",
            assetName: "Earth",
            summary: "액체 상태의 바다가 있는 행성",
            displaySize: 50,
            orbitRadius: 168,
            orbitDuration: 16,
            rotationDuration: 3
        ),
        Planet(
            name: "화성",
            assetName: "Mars",
            summary: "산화철 때문에 붉게 보이는 행성",
            displaySize: 46,
            orbitRadius: 206,
            orbitDuration: 22,
            rotationDuration: 3.2
        ),
        Planet(
            name: "목성",
            assetName: "Jupiter",
            summary: "태양계에서 가장 큰 가스 행성",
            displaySize: 74,
            orbitRadius: 252,
            orbitDuration: 32,
            rotationDuration: 2.2
        ),
        Planet(
            name: "토성",
            assetName: "Saturn",
            summary: "뚜렷한 고리로 알려진 가스 행성",
            displaySize: 72,
            orbitRadius: 296,
            orbitDuration: 42,
            rotationDuration: 2.5
        ),
        Planet(
            name: "천왕성",
            assetName: "Uranus",
            summary: "자전축이 크게 기울어진 얼음 행성",
            displaySize: 58,
            orbitRadius: 336,
            orbitDuration: 54,
            rotationDuration: 3.8
        ),
        Planet(
            name: "해왕성",
            assetName: "Neptune",
            summary: "빠른 바람이 부는 얼음 행성",
            displaySize: 58,
            orbitRadius: 374,
            orbitDuration: 66,
            rotationDuration: 4
        )
    ]
}
