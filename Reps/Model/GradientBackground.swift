import SwiftUI
import FirebaseFirestore

struct GradientBackground: ViewModifier {
    @State private var startPoint = UnitPoint.topLeading
    @State private var endPoint = UnitPoint.bottomTrailing

    var index: Int

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hue: Double(index) * 0.1, saturation: 0.8, brightness: 1),
                        Color(hue: Double(index) * 0.1 + 0.1, saturation: 0.8, brightness: 1)
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
