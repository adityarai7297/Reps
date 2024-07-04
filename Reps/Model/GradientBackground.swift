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
                        Color(hue: Double(index) * 0.1, saturation: 0.3, brightness: 0.9),
                        Color(hue: Double(index) * 0.1 + 0.1, saturation: 0.3, brightness: 0.9)
                    ]),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                //.animation(
                   // Animation.linear(duration: 5)
                    //    .repeatForever(autoreverses: true)
                     //   .delay(Double(index) * 0.1)
               // )
            )
            //.onAppear {
               // startPoint = UnitPoint(x: Double.random(in: 0...1), y: Double.random(in: 0...1))
                //endPoint = UnitPoint(x: Double.random(in: 0...1), y: Double.random(in: 0...1))
           // }
    }
}

extension View {
    func gradientBackground(index: Int) -> some View {
        self.modifier(GradientBackground(index: index))
    }
}
