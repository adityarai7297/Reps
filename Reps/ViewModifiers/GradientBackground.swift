import SwiftUI
import IrregularGradient

struct GradientBackground: ViewModifier {
    let colors: (Color, Color)
    
    init(colors: (Color, Color)) {
        self.colors = colors
    }
    
    func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .irregularGradient(
                    colors: [colors.0, colors.1],
                    background: colors.0.opacity(0.3),
                    speed: 0.8
                )
            
            content
        }
    }
}

extension View {
    func gradientBackground(colors: (Color, Color)) -> some View {
        modifier(GradientBackground(colors: colors))
    }
}
