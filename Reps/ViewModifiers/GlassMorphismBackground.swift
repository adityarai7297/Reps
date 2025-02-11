import SwiftUI

struct GlassMorphismBackground: ViewModifier {
    let colors: (Color, Color)
    @State private var animateGradient = false
    
    func body(content: Content) -> some View {
        ZStack {
            // Base gradient layer
            LinearGradient(
                gradient: Gradient(colors: [colors.0, colors.1]),
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .blur(radius: 50)
            .onAppear {
                withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            // Animated morphing circles
            GeometryReader { geometry in
                ZStack {
                    // First morphing circle
                    Circle()
                        .fill(colors.0)
                        .frame(width: geometry.size.width * 0.6)
                        .offset(x: -geometry.size.width * 0.1, y: -geometry.size.height * 0.2)
                        .blur(radius: 60)
                        .opacity(0.8)
                    
                    // Second morphing circle
                    Circle()
                        .fill(colors.1)
                        .frame(width: geometry.size.width * 0.6)
                        .offset(x: geometry.size.width * 0.4, y: geometry.size.height * 0.4)
                        .blur(radius: 60)
                        .opacity(0.8)
                }
            }
            
            // Frosted glass effect overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.5)
            
            content
        }
        .ignoresSafeArea()
    }
}

// Extension to make it easier to use
extension View {
    func glassMorphismBackground(colors: (Color, Color)) -> some View {
        modifier(GlassMorphismBackground(colors: colors))
    }
} 