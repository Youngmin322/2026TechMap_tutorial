import Foundation

struct Planet: Identifiable, Hashable {
    let name: String
    let assetName: String

    var id: String { assetName }

    static let starter: [Planet] = [
        .init(name: "수성", assetName: "Mercury"),
        .init(name: "금성", assetName: "Venus"),
        .init(name: "지구", assetName: "Earth"),
        .init(name: "화성", assetName: "Mars"),
        .init(name: "목성", assetName: "Jupiter"),
        .init(name: "토성", assetName: "Saturn"),
        .init(name: "천왕성", assetName: "Uranus"),
        .init(name: "해왕성", assetName: "Neptune")
    ]
}
