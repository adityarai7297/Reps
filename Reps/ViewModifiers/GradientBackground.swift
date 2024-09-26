import SwiftUI

struct GradientBackground: ViewModifier {
    @State private var startPoint = UnitPoint.topLeading
    @State private var endPoint = UnitPoint.bottomTrailing

    var index: Int

    func body(content: Content) -> some View {
        let hueOffset = (Double(index % 10) * 0.08) // Cycle hue every 10 views
        let baseHue = (Double(index / 10) * 0.3).truncatingRemainder(dividingBy: 1.0) // Gradually change hue with cycles
        let hue1 = baseHue + hueOffset
        let hue2 = baseHue + hueOffset + 0.1

        content
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hue: hue1, saturation: 0.8, brightness: 1),
                        Color(hue: hue2.truncatingRemainder(dividingBy: 1.0), saturation: 0.8, brightness: 1)
                    ]),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
    }
}

extension View {
    func gradientBackground(index: Int) -> some View {
        self.modifier(GradientBackground(index: index))
    }
}
