import Foundation

struct Planet: Identifiable, Hashable {
    let name: String
    let assetName: String
    let summary: String
    let displaySize: Double
    let orbitRadius: Double
    let orbitDuration: Double
    let rotationDuration: Double
    let rotationDirection: Double

    var id: String { assetName }
}
