import Foundation

struct Planet: Identifiable, Hashable {
    let name: String
    let assetName: String
    let summary: String
    let displaySize: CGFloat
    let depth: CGFloat
    let orbitRadius: CGFloat
    let orbitDuration: TimeInterval
    let rotationDuration: TimeInterval
    let rotationDirection: Double

    var id: String { assetName }

    static let starter: [Planet] = [
        .init(name: "수성", assetName: "Mercury", summary: "태양에 가장 가까운 행성", displaySize: 42, depth: -70, orbitRadius: 92, orbitDuration: 8, rotationDuration: 2.4, rotationDirection: 1),
        .init(name: "금성", assetName: "Venus", summary: "두꺼운 대기를 가진 암석 행성", displaySize: 48, depth: -50, orbitRadius: 130, orbitDuration: 12, rotationDuration: 3.8, rotationDirection: -1),
        .init(name: "지구", assetName: "Earth", summary: "액체 상태의 바다가 있는 행성", displaySize: 50, depth: -30, orbitRadius: 168, orbitDuration: 16, rotationDuration: 2.8, rotationDirection: 1),
        .init(name: "화성", assetName: "Mars", summary: "산화철 때문에 붉게 보이는 행성", displaySize: 46, depth: -10, orbitRadius: 206, orbitDuration: 20, rotationDuration: 3, rotationDirection: 1),
        .init(name: "목성", assetName: "Jupiter", summary: "태양계에서 가장 큰 가스 행성", displaySize: 74, depth: 10, orbitRadius: 252, orbitDuration: 25, rotationDuration: 2.2, rotationDirection: 1),
        .init(name: "토성", assetName: "Saturn", summary: "뚜렷한 고리로 알려진 가스 행성", displaySize: 72, depth: 30, orbitRadius: 296, orbitDuration: 30, rotationDuration: 2.5, rotationDirection: 1),
        .init(name: "천왕성", assetName: "Uranus", summary: "자전축이 크게 기울어진 얼음 행성", displaySize: 58, depth: 50, orbitRadius: 336, orbitDuration: 36, rotationDuration: 3.2, rotationDirection: -1),
        .init(name: "해왕성", assetName: "Neptune", summary: "빠른 바람이 부는 얼음 행성", displaySize: 58, depth: 70, orbitRadius: 374, orbitDuration: 42, rotationDuration: 3.1, rotationDirection: 1)
    ]
}
