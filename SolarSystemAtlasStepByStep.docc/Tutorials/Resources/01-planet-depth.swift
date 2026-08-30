import Foundation

struct Planet: Identifiable, Hashable {
    let name: String
    let assetName: String
    let depth: CGFloat

    var id: String { assetName }

    static let starter: [Planet] = [
        .init(name: "수성", assetName: "Mercury", depth: -70),
        .init(name: "금성", assetName: "Venus", depth: -50),
        .init(name: "지구", assetName: "Earth", depth: -30),
        .init(name: "화성", assetName: "Mars", depth: -10),
        .init(name: "목성", assetName: "Jupiter", depth: 10),
        .init(name: "토성", assetName: "Saturn", depth: 30),
        .init(name: "천왕성", assetName: "Uranus", depth: 50),
        .init(name: "해왕성", assetName: "Neptune", depth: 70)
    ]
}
