import SwiftUI
import RealityKit

struct PlanetLabels: View {
    var body: some View {
        RealityView { content, _ in
            let root = Entity()
            root.name = "solar-system-root"
            content.add(root)
        } attachments: {
            // 다음 단계에서 행성 레이블을 추가합니다.
        }
    }
}
