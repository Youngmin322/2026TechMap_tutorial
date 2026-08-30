import SwiftUI

struct SelectablePlanetView: View {
    let planet: Planet
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        PlanetModelView(assetName: planet.assetName)
            .frame(width: isSelected ? 102 : 84)
            .hoverEffect()
            .onTapGesture(perform: select)
    }
}
