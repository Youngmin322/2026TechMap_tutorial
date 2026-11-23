import Foundation

struct Planet: Identifiable, Hashable {
    let name: String
    let assetName: String
    let summary: String
    let size: Float
    let orbitRadius: Float
    let orbitDuration: TimeInterval

    var id: String { assetName }

    static let all: [Planet] = [
        .init(name: "수성", assetName: "Mercury", summary: "태양에 가장 가까운 행성", size: 0.038, orbitRadius: 0.09, orbitDuration: 8),
        .init(name: "금성", assetName: "Venus", summary: "두꺼운 대기를 가진 암석 행성", size: 0.044, orbitRadius: 0.13, orbitDuration: 12),
        .init(name: "지구", assetName: "Earth", summary: "액체 상태의 바다가 있는 행성", size: 0.046, orbitRadius: 0.17, orbitDuration: 16),
        .init(name: "화성", assetName: "Mars", summary: "산화철 때문에 붉게 보이는 행성", size: 0.042, orbitRadius: 0.21, orbitDuration: 22),
        .init(name: "목성", assetName: "Jupiter", summary: "태양계에서 가장 큰 가스 행성", size: 0.068, orbitRadius: 0.26, orbitDuration: 32),
        .init(name: "토성", assetName: "Saturn", summary: "뚜렷한 고리를 가진 가스 행성", size: 0.066, orbitRadius: 0.30, orbitDuration: 42),
        .init(name: "천왕성", assetName: "Uranus", summary: "자전축이 크게 기울어진 얼음 행성", size: 0.052, orbitRadius: 0.34, orbitDuration: 54),
        .init(name: "해왕성", assetName: "Neptune", summary: "빠른 바람이 부는 얼음 행성", size: 0.052, orbitRadius: 0.38, orbitDuration: 66)
    ]
}
