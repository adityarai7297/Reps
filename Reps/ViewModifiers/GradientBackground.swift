import SwiftUI

struct GradientBackground: ViewModifier {
    @State private var startPoint = UnitPoint.topLeading
    @State private var endPoint = UnitPoint.bottomTrailing

    var index: Int
    
    // Combined and ordered list of gradients by color similarity
    private let gradients: [[Color]] = [
        [Color(hex: "#1565C0"), Color(hex: "#b92b27")],               // Dark Blue to Dark Red
        [Color(hex: "#2980B9"), Color(hex: "#6DD5FA"), Color(hex: "#FFFFFF")], // Blue to Light Blue to White
        [Color(hex: "#FF0099"), Color(hex: "#493240")],               // Pink to Dark Purple
        [Color(hex: "#1f4037"), Color(hex: "#99f2c8")],               // Dark Green to Light Mint
        [Color(hex: "#7F7FD5"), Color(hex: "#86A8E7"), Color(hex: "#91EAE4")], // Purple to Light Blue
        [Color(hex: "#f12711"), Color(hex: "#f5af19")],               // Red to Orange
        [Color(hex: "#009FFF"), Color(hex: "#ec2F4B")],               // Blue to Red
        [Color(hex: "#654ea3"), Color(hex: "#eaafc8")],               // Purple to Light Pink
        [Color(hex: "#8A2387"), Color(hex: "#E94057"), Color(hex: "#F27121")], // Dark Purple to Orange
        [Color(hex: "#00F260"), Color(hex: "#0575E6")],               // Green to Blue
        [Color(hex: "#DCE35B"), Color(hex: "#45B649")],               // Light Green to Dark Green
        [Color(hex: "#5433FF"), Color(hex: "#20BDFF"), Color(hex: "#A5FECB")], // Purple to Light Blue to Mint
        [Color(hex: "#e1eec3"), Color(hex: "#f05053")],               // Light Green to Red
        [Color(hex: "#f7ff00"), Color(hex: "#db36a4")],               // Yellow to Pink
        [Color(hex: "#FDFC47"), Color(hex: "#24FE41")],               // Yellow to Green
        [Color(hex: "#40E0D0"), Color(hex: "#FF8C00"), Color(hex: "#FF0080")], // Turquoise to Orange to Pink
        [Color(hex: "#833ab4"), Color(hex: "#fd1d1d"), Color(hex: "#FF0080")],  // Dark Purple to Red to Pink
        [Color(hex: "#5614B0"), Color(hex: "#DBD65C")]                // Dark Purple to Yellow-Gold
    ]
    
    func body(content: Content) -> some View {
        // Select a gradient based on index, cycling through the array
        let gradientColors = gradients[index % gradients.count]
        
        content
            .background(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
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
