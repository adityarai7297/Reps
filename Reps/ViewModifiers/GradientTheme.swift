import SwiftUI
import IrregularGradient

struct GradientPair {
    let start: Color
    let end: Color
    let name: String
    
    static func gradient(_ pair: GradientPair) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [pair.start, pair.end]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func animatedGradient(_ pair: GradientPair) -> some View {
        Rectangle()
            .irregularGradient(
                colors: [pair.start, pair.end],
                background: pair.start.opacity(0.3),
                speed: 0.8
            )
    }
}

struct GradientTheme {
    static let gradients: [GradientPair] = [
        // Deep purple to hot pink
        GradientPair(
            start: Color(red: 0.4, green: 0.1, blue: 0.6),
            end: Color(red: 0.8, green: 0.2, blue: 0.4),
            name: "Purple Pink"
        ),
        
        // Deep blue to turquoise
        GradientPair(
            start: Color(red: 0.1, green: 0.2, blue: 0.8),
            end: Color(red: 0.2, green: 0.6, blue: 0.7),
            name: "Ocean Breeze"
        ),
        
        // Deep red to orange
        GradientPair(
            start: Color(red: 0.7, green: 0.1, blue: 0.2),
            end: Color(red: 0.9, green: 0.4, blue: 0.1),
            name: "Sunset"
        ),
        
        // Deep indigo to electric cyan
        GradientPair(
            start: Color(red: 0.2, green: 0.1, blue: 0.8),
            end: Color(red: 0.1, green: 0.8, blue: 0.9),
            name: "Electric Ocean"
        ),
        
        // Deep magenta to coral
        GradientPair(
            start: Color(red: 0.6, green: 0.1, blue: 0.5),
            end: Color(red: 0.95, green: 0.4, blue: 0.3),
            name: "Magenta Coral"
        ),
        
        // Deep emerald to lime
        GradientPair(
            start: Color(red: 0.1, green: 0.5, blue: 0.3),
            end: Color(red: 0.5, green: 0.9, blue: 0.2),
            name: "Forest Spring"
        ),
        
        // Deep violet to rose
        GradientPair(
            start: Color(red: 0.4, green: 0.1, blue: 0.7),
            end: Color(red: 0.9, green: 0.2, blue: 0.5),
            name: "Violet Rose"
        ),
        
        // Deep sapphire to aqua
        GradientPair(
            start: Color(red: 0.1, green: 0.2, blue: 0.6),
            end: Color(red: 0.2, green: 0.8, blue: 0.8),
            name: "Sapphire Aqua"
        ),
        
        // Deep crimson to amber
        GradientPair(
            start: Color(red: 0.7, green: 0.1, blue: 0.2),
            end: Color(red: 1.0, green: 0.7, blue: 0.2),
            name: "Crimson Gold"
        ),
        
        // Deep purple to electric blue
        GradientPair(
            start: Color(red: 0.3, green: 0.1, blue: 0.6),
            end: Color(red: 0.2, green: 0.4, blue: 1.0),
            name: "Royal Electric"
        ),
        
        // Deep burgundy to peach
        GradientPair(
            start: Color(red: 0.5, green: 0.1, blue: 0.2),
            end: Color(red: 1.0, green: 0.5, blue: 0.4),
            name: "Burgundy Peach"
        ),
        
        // Deep cobalt to electric green
        GradientPair(
            start: Color(red: 0.15, green: 0.2, blue: 0.7),
            end: Color(red: 0.3, green: 0.9, blue: 0.4),
            name: "Cobalt Emerald"
        ),
        
        // Deep plum to hot coral
        GradientPair(
            start: Color(red: 0.5, green: 0.1, blue: 0.5),
            end: Color(red: 1.0, green: 0.4, blue: 0.3),
            name: "Plum Coral"
        ),
        
        // Deep navy to electric yellow
        GradientPair(
            start: Color(red: 0.1, green: 0.15, blue: 0.6),
            end: Color(red: 0.95, green: 0.85, blue: 0.2),
            name: "Navy Sun"
        ),
        
        // Deep forest to azure
        GradientPair(
            start: Color(red: 0.1, green: 0.4, blue: 0.2),
            end: Color(red: 0.2, green: 0.7, blue: 0.9),
            name: "Forest Lake"
        ),
        
        // Deep raspberry to golden
        GradientPair(
            start: Color(red: 0.6, green: 0.1, blue: 0.3),
            end: Color(red: 0.9, green: 0.8, blue: 0.2),
            name: "Raspberry Gold"
        ),
        
        // Deep turquoise to fuchsia
        GradientPair(
            start: Color(red: 0.1, green: 0.5, blue: 0.5),
            end: Color(red: 0.9, green: 0.2, blue: 0.7),
            name: "Turquoise Rose"
        ),
        
        // Deep amethyst to neon blue
        GradientPair(
            start: Color(red: 0.4, green: 0.2, blue: 0.7),
            end: Color(red: 0.2, green: 0.5, blue: 1.0),
            name: "Amethyst Sky"
        ),
        
        // Deep scarlet to electric lime
        GradientPair(
            start: Color(red: 0.7, green: 0.1, blue: 0.1),
            end: Color(red: 0.6, green: 1.0, blue: 0.2),
            name: "Scarlet Lime"
        ),
        
        // Deep indigo to sunset orange
        GradientPair(
            start: Color(red: 0.2, green: 0.1, blue: 0.5),
            end: Color(red: 1.0, green: 0.5, blue: 0.2),
            name: "Indigo Sunset"
        )
    ]
    
    static func randomGradient() -> GradientPair {
        gradients.randomElement()!
    }
    
    static func gradientAt(index: Int) -> GradientPair {
        gradients[index % gradients.count]
    }
}