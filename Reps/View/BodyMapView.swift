import SwiftUI

struct BodyMapView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                BodyMapShape()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 300, height: 400)
                    .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Body Map")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct BodyMapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Scale factors
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        
        // Head
        path.addEllipse(in: CGRect(x: centerX - 30, y: 10, width: 60, height: 60))
        
        // Neck
        path.move(to: CGPoint(x: centerX, y: 70))
        path.addLine(to: CGPoint(x: centerX, y: 90))
        
        // Shoulders
        path.move(to: CGPoint(x: centerX, y: 90))
        path.addCurve(
            to: CGPoint(x: centerX - 60, y: 100),
            control1: CGPoint(x: centerX - 20, y: 90),
            control2: CGPoint(x: centerX - 40, y: 95)
        )
        
        path.move(to: CGPoint(x: centerX, y: 90))
        path.addCurve(
            to: CGPoint(x: centerX + 60, y: 100),
            control1: CGPoint(x: centerX + 20, y: 90),
            control2: CGPoint(x: centerX + 40, y: 95)
        )
        
        // Arms
        path.move(to: CGPoint(x: centerX - 60, y: 100))
        path.addLine(to: CGPoint(x: centerX - 80, y: 180))
        
        path.move(to: CGPoint(x: centerX + 60, y: 100))
        path.addLine(to: CGPoint(x: centerX + 80, y: 180))
        
        // Chest
        path.move(to: CGPoint(x: centerX - 40, y: 110))
        path.addCurve(
            to: CGPoint(x: centerX + 40, y: 110),
            control1: CGPoint(x: centerX - 20, y: 120),
            control2: CGPoint(x: centerX + 20, y: 120)
        )
        
        // Abs
        let absStartY = 130
        let absSpacing = 20
        for i in 0..<4 {
            let y = CGFloat(absStartY + (i * absSpacing))
            path.move(to: CGPoint(x: centerX - 20, y: y))
            path.addLine(to: CGPoint(x: centerX + 20, y: y))
        }
        
        // Legs
        path.move(to: CGPoint(x: centerX - 20, y: 200))
        path.addLine(to: CGPoint(x: centerX - 40, y: 300))
        
        path.move(to: CGPoint(x: centerX + 20, y: 200))
        path.addLine(to: CGPoint(x: centerX + 40, y: 300))
        
        // Calves
        path.move(to: CGPoint(x: centerX - 40, y: 300))
        path.addLine(to: CGPoint(x: centerX - 50, y: 380))
        
        path.move(to: CGPoint(x: centerX + 40, y: 300))
        path.addLine(to: CGPoint(x: centerX + 50, y: 380))
        
        return path
    }
} 
