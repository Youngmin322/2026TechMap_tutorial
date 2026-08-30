import Foundation

struct Planet: Identifiable, Hashable {
    let name: String
    let assetName: String
    let depth: CGFloat
    let orbitRadius: CGFloat
    let orbitDuration: TimeInterval
    let rotationDuration: TimeInterval
    let rotationDirection: Double

    var id: String { assetName }

    static let starter: [Planet] = [
        .init(name: "수성", assetName: "Mercury", depth: -70, orbitRadius: 56, orbitDuration: 10, rotationDuration: 2.8, rotationDirection: 1),
        .init(name: "금성", assetName: "Venus", depth: -50, orbitRadius: 84, orbitDuration: 14, rotationDuration: 4.2, rotationDirection: -1),
        .init(name: "지구", assetName: "Earth", depth: -30, orbitRadius: 112, orbitDuration: 18, rotationDuration: 3, rotationDirection: 1),
        .init(name: "화성", assetName: "Mars", depth: -10, orbitRadius: 140, orbitDuration: 22, rotationDuration: 3.2, rotationDirection: 1),
        .init(name: "목성", assetName: "Jupiter", depth: 10, orbitRadius: 172, orbitDuration: 28, rotationDuration: 2.4, rotationDirection: 1),
        .init(name: "토성", assetName: "Saturn", depth: 30, orbitRadius: 204, orbitDuration: 34, rotationDuration: 2.7, rotationDirection: 1),
        .init(name: "천왕성", assetName: "Uranus", depth: 50, orbitRadius: 236, orbitDuration: 40, rotationDuration: 3.6, rotationDirection: -1),
        .init(name: "해왕성", assetName: "Neptune", depth: 70, orbitRadius: 268, orbitDuration: 46, rotationDuration: 3.4, rotationDirection: 1)
    ]
}
