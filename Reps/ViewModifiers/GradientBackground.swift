import SwiftUI

struct GradientBackground: ViewModifier {
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    private func calculateGlowSpread(_ geometry: GeometryProxy) -> CGFloat {
        #if os(iOS)
        let pointsPerInch = UIScreen.main.scale * 72.0
        let glowWidth = pointsPerInch / 24.0
        #else
        let glowWidth: CGFloat = 3.0
        #endif
        
        let screenSmallestDimension = min(geometry.size.width, geometry.size.height)
        return min(glowWidth, screenSmallestDimension * 0.1)
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                // Base background
                themeManager.backgroundColor
                
                // Gradient layers
                Color(color)
                    .opacity(themeManager.isDarkMode ? 0.5 : 0.3)
                    .blur(radius: calculateGlowSpread(geometry) * 0.8)
                    .mask {
                        ZStack {
                            Rectangle().fill(themeManager.isDarkMode ? .black : .white)
                            RoundedRectangle(cornerRadius: 40)
                                .padding(calculateGlowSpread(geometry) * 0.45)
                                .blur(radius: calculateGlowSpread(geometry) * 0.4)
                                .blendMode(.destinationOut)
                        }
                    }
                
                Color(color)
                    .opacity(themeManager.isDarkMode ? 0.3 : 0.2)
                    .blur(radius: calculateGlowSpread(geometry) * 1.0)
                    .mask {
                        ZStack {
                            Rectangle().fill(themeManager.isDarkMode ? .black : .white)
                            RoundedRectangle(cornerRadius: 40)
                                .padding(calculateGlowSpread(geometry) * 0.8)
                                .blur(radius: calculateGlowSpread(geometry) * 0.6)
                                .blendMode(.destinationOut)
                        }
                    }
                
                content
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 40))
    }
}

// Extension to make it easier to use
extension View {
    func gradientBackground(color: Color = .green) -> some View {
        modifier(GradientBackground(color: color))
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
