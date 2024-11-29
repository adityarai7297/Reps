import SwiftUI

struct GradientBackground: ViewModifier {
    @State private var phase = 0.0
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    // Adjusted colors for more visible inner glow effect
    private let gradientColors: [Color] = [
        Color.green,                 // Solid inner glow
        Color.green.opacity(0.8),    // Strong fade
        Color.green.opacity(0.4),    // Mid fade
        Color.clear                  // Transparent edge
    ]
    
    private func calculateGlowSpread(_ geometry: GeometryProxy) -> CGFloat {
        #if os(iOS)
        let pointsPerInch = UIScreen.main.scale * 72.0
        let glowWidth = pointsPerInch / 18.0
        #else
        let glowWidth: CGFloat = 4.0
        #endif
        
        let screenSmallestDimension = min(geometry.size.width, geometry.size.height)
        return min(glowWidth, screenSmallestDimension * 0.15)
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                // Base white background
                Color.white
                
                // Inner glow
                Color.green.opacity(0.7)
                    .blur(radius: calculateGlowSpread(geometry) * 0.8)
                    .mask {
                        // Create inverse mask with gradient edges
                        ZStack {
                            Rectangle().fill(.white)
                            RoundedRectangle(cornerRadius: 40)
                                .padding(calculateGlowSpread(geometry) * 0.45)
                                .blur(radius: calculateGlowSpread(geometry) * 0.4)
                                .blendMode(.destinationOut)
                        }
                    }
                
                // Second layer for extra dispersion
                Color.green.opacity(0.5)
                    .blur(radius: calculateGlowSpread(geometry) * 1.0)
                    .mask {
                        ZStack {
                            Rectangle().fill(.white)
                            RoundedRectangle(cornerRadius: 40)
                                .padding(calculateGlowSpread(geometry) * 0.8)
                                .blur(radius: calculateGlowSpread(geometry) * 0.6)
                                .blendMode(.destinationOut)
                        }
                    }
                
                // Content on top
                content
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: 0.016)) {
                phase += 0.016
            }
        }
    }
}

// Extension to make it easier to use
extension View {
    func gradientBackground() -> some View {
        modifier(GradientBackground())
    }
}

// Hex Color Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
