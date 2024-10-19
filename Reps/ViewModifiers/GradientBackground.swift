import SwiftUI

struct GradientBackground: ViewModifier {
    @State private var startPoint = UnitPoint.topLeading
    @State private var endPoint = UnitPoint.bottomTrailing

    var index: Int
    var randomSeed: Double

    func body(content: Content) -> some View {
        // Generate a pseudo-random hue based on the index and randomSeed
        let hue = abs((sin(Double(index) * 12.9898 + randomSeed) * 43758.5453).truncatingRemainder(dividingBy: 1.0))
        let hue1 = hue
        let hue2 = (hue + 0.1).truncatingRemainder(dividingBy: 1.0)

        content
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hue: hue1, saturation: 0.8, brightness: 1),
                        Color(hue: hue2, saturation: 0.8, brightness: 1)
                    ]),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
    }
}

extension View {
    func gradientBackground(index: Int, randomSeed: Double) -> some View {
        self.modifier(GradientBackground(index: index, randomSeed: randomSeed))
    }
}
