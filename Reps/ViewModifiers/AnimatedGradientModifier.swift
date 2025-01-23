import SwiftUI
import IrregularGradient

struct AnimatedGradientModifier: ViewModifier {
    let gradientPair: GradientPair
    
    func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .irregularGradient(
                    colors: [gradientPair.start, gradientPair.end],
                    background: gradientPair.start.opacity(0.3),
                    speed: 0.4
                )
                .scaleEffect(1.5)
            
            content
        }
    }
}

extension View {
    func animatedGradient(using gradientPair: GradientPair) -> some View {
        modifier(AnimatedGradientModifier(gradientPair: gradientPair))
    }
} 
