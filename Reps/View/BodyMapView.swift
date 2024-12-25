import SwiftUI

enum MuscleGroup: String, CaseIterable {
    // Front muscles
    case chest = "Chest"
    case frontShoulders = "Front Deltoids"
    case biceps = "Biceps"
    case abs = "Abs"
    case quads = "Quadriceps"
    case calves = "Calves"
    
    // Back muscles
    case traps = "Trapezius"
    case backShoulders = "Rear Deltoids"
    case lats = "Lats"
    case triceps = "Triceps"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
}

struct BodyMapView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var hoveredMuscleGroup: MuscleGroup?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    // Muscle map
                    MuscleMapShape(selectedGroup: selectedMuscleGroup)
                        .stroke(Color.white, lineWidth: 1.5)
                        .overlay(
                            MuscleMapShape(selectedGroup: selectedMuscleGroup)
                                .fill(Color.white.opacity(0.1))
                        )
                        .frame(width: 300, height: 400)
                        .padding()
                    
                    // Muscle group selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(MuscleGroup.allCases, id: \.self) { group in
                                Button(action: {
                                    withAnimation {
                                        selectedMuscleGroup = selectedMuscleGroup == group ? nil : group
                                    }
                                }) {
                                    Text(group.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedMuscleGroup == group ? .white : .gray)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedMuscleGroup == group ? 
                                                Color.white.opacity(0.2) : 
                                                Color.white.opacity(0.1)
                                        )
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
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

struct MuscleMapShape: Shape {
    let selectedGroup: MuscleGroup?
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        
        // Head
        path.addEllipse(in: CGRect(x: centerX - 25, y: 10, width: 50, height: 60))
        
        // Neck - trapezius area
        path.move(to: CGPoint(x: centerX - 25, y: 70))
        path.addCurve(
            to: CGPoint(x: centerX + 25, y: 70),
            control1: CGPoint(x: centerX - 15, y: 75),
            control2: CGPoint(x: centerX + 15, y: 75)
        )
        
        // Shoulders - deltoids
        path.move(to: CGPoint(x: centerX - 25, y: 80))
        path.addQuadCurve(
            to: CGPoint(x: centerX - 70, y: 100),
            control: CGPoint(x: centerX - 55, y: 85)
        )
        
        path.move(to: CGPoint(x: centerX + 25, y: 80))
        path.addQuadCurve(
            to: CGPoint(x: centerX + 70, y: 100),
            control: CGPoint(x: centerX + 55, y: 85)
        )
        
        // Arms - biceps and triceps
        // Left arm
        path.move(to: CGPoint(x: centerX - 70, y: 100))
        path.addCurve(
            to: CGPoint(x: centerX - 75, y: 160),
            control1: CGPoint(x: centerX - 80, y: 120),
            control2: CGPoint(x: centerX - 85, y: 140)
        )
        
        // Left forearm
        path.addCurve(
            to: CGPoint(x: centerX - 65, y: 200),
            control1: CGPoint(x: centerX - 70, y: 175),
            control2: CGPoint(x: centerX - 65, y: 190)
        )
        
        // Right arm
        path.move(to: CGPoint(x: centerX + 70, y: 100))
        path.addCurve(
            to: CGPoint(x: centerX + 75, y: 160),
            control1: CGPoint(x: centerX + 80, y: 120),
            control2: CGPoint(x: centerX + 85, y: 140)
        )
        
        // Right forearm
        path.addCurve(
            to: CGPoint(x: centerX + 65, y: 200),
            control1: CGPoint(x: centerX + 70, y: 175),
            control2: CGPoint(x: centerX + 65, y: 190)
        )
        
        // Chest - pectorals
        path.move(to: CGPoint(x: centerX - 60, y: 100))
        path.addCurve(
            to: CGPoint(x: centerX + 60, y: 100),
            control1: CGPoint(x: centerX - 30, y: 120),
            control2: CGPoint(x: centerX + 30, y: 120)
        )
        
        // Abs - six pack definition
        let absWidth: CGFloat = 20
        for i in 0..<3 {
            let y = 140 + CGFloat(i * 30)
            
            // Left ab
            path.move(to: CGPoint(x: centerX - absWidth, y: y))
            path.addCurve(
                to: CGPoint(x: centerX - absWidth, y: y + 20),
                control1: CGPoint(x: centerX - absWidth - 5, y: y + 10),
                control2: CGPoint(x: centerX - absWidth - 5, y: y + 20)
            )
            
            // Right ab
            path.move(to: CGPoint(x: centerX + absWidth, y: y))
            path.addCurve(
                to: CGPoint(x: centerX + absWidth, y: y + 20),
                control1: CGPoint(x: centerX + absWidth + 5, y: y + 10),
                control2: CGPoint(x: centerX + absWidth + 5, y: y + 20)
            )
        }
        
        // Obliques
        path.move(to: CGPoint(x: centerX - 40, y: 130))
        path.addCurve(
            to: CGPoint(x: centerX - 45, y: 220),
            control1: CGPoint(x: centerX - 45, y: 160),
            control2: CGPoint(x: centerX - 48, y: 190)
        )
        
        path.move(to: CGPoint(x: centerX + 40, y: 130))
        path.addCurve(
            to: CGPoint(x: centerX + 45, y: 220),
            control1: CGPoint(x: centerX + 45, y: 160),
            control2: CGPoint(x: centerX + 48, y: 190)
        )
        
        // Legs - quadriceps
        // Left quad
        path.move(to: CGPoint(x: centerX - 45, y: 220))
        path.addCurve(
            to: CGPoint(x: centerX - 40, y: 300),
            control1: CGPoint(x: centerX - 55, y: 250),
            control2: CGPoint(x: centerX - 50, y: 280)
        )
        
        // Right quad
        path.move(to: CGPoint(x: centerX + 45, y: 220))
        path.addCurve(
            to: CGPoint(x: centerX + 40, y: 300),
            control1: CGPoint(x: centerX + 55, y: 250),
            control2: CGPoint(x: centerX + 50, y: 280)
        )
        
        // Calves
        // Left calf
        path.move(to: CGPoint(x: centerX - 40, y: 300))
        path.addCurve(
            to: CGPoint(x: centerX - 35, y: 380),
            control1: CGPoint(x: centerX - 45, y: 330),
            control2: CGPoint(x: centerX - 40, y: 360)
        )
        
        // Right calf
        path.move(to: CGPoint(x: centerX + 40, y: 300))
        path.addCurve(
            to: CGPoint(x: centerX + 35, y: 380),
            control1: CGPoint(x: centerX + 45, y: 330),
            control2: CGPoint(x: centerX + 40, y: 360)
        )
        
        return path
    }
}

struct FrontMuscleMap: Shape {
    let selectedGroup: MuscleGroup?
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        
        // Head (for reference)
        path.addEllipse(in: CGRect(x: centerX - 25, y: 10, width: 50, height: 60))
        
        // Neck
        path.move(to: CGPoint(x: centerX - 15, y: 70))
        path.addLine(to: CGPoint(x: centerX + 15, y: 70))
        
        // Front Deltoids
        let shoulderHighlight = selectedGroup == MuscleGroup.frontShoulders
        path.move(to: CGPoint(x: centerX - 15, y: 75))
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX - 60, y: 85),
            CGPoint(x: centerX - 65, y: 95),
            CGPoint(x: centerX - 60, y: 105),
            CGPoint(x: centerX - 40, y: 90)
        ], highlight: shoulderHighlight)
        
        // Mirror for right shoulder
        path.move(to: CGPoint(x: centerX + 15, y: 75))
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX + 60, y: 85),
            CGPoint(x: centerX + 65, y: 95),
            CGPoint(x: centerX + 60, y: 105),
            CGPoint(x: centerX + 40, y: 90)
        ], highlight: shoulderHighlight)
        
        // Chest
        let chestHighlight = selectedGroup == MuscleGroup.chest
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX - 60, y: 95),
            CGPoint(x: centerX - 40, y: 105),
            CGPoint(x: centerX, y: 120),
            CGPoint(x: centerX + 40, y: 105),
            CGPoint(x: centerX + 60, y: 95),
            CGPoint(x: centerX + 40, y: 130),
            CGPoint(x: centerX, y: 140),
            CGPoint(x: centerX - 40, y: 130)
        ], highlight: chestHighlight)
        
        // Biceps
        let bicepsHighlight = selectedGroup == MuscleGroup.biceps
        // Left bicep
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX - 65, y: 95),
            CGPoint(x: centerX - 75, y: 120),
            CGPoint(x: centerX - 70, y: 145),
            CGPoint(x: centerX - 60, y: 150),
            CGPoint(x: centerX - 55, y: 120)
        ], highlight: bicepsHighlight)
        
        // Right bicep
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX + 65, y: 95),
            CGPoint(x: centerX + 75, y: 120),
            CGPoint(x: centerX + 70, y: 145),
            CGPoint(x: centerX + 60, y: 150),
            CGPoint(x: centerX + 55, y: 120)
        ], highlight: bicepsHighlight)
        
        // Abs
        let absHighlight = selectedGroup == MuscleGroup.abs
        // Upper abs
        for i in 0..<3 {
            let y = CGFloat(140 + (i * 35))
            addMuscleGroup(to: &path, points: [
                CGPoint(x: centerX - 25, y: y),
                CGPoint(x: centerX - 25, y: y + 30),
                CGPoint(x: centerX, y: y + 32),
                CGPoint(x: centerX + 25, y: y + 30),
                CGPoint(x: centerX + 25, y: y),
                CGPoint(x: centerX, y: y + 2)
            ], highlight: absHighlight)
        }
        
        // Quads
        let quadsHighlight = selectedGroup == MuscleGroup.quads
        // Left quad
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX - 30, y: 245),
            CGPoint(x: centerX - 45, y: 280),
            CGPoint(x: centerX - 40, y: 320),
            CGPoint(x: centerX - 25, y: 330),
            CGPoint(x: centerX - 20, y: 280)
        ], highlight: quadsHighlight)
        
        // Right quad
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX + 30, y: 245),
            CGPoint(x: centerX + 45, y: 280),
            CGPoint(x: centerX + 40, y: 320),
            CGPoint(x: centerX + 25, y: 330),
            CGPoint(x: centerX + 20, y: 280)
        ], highlight: quadsHighlight)
        
        // Calves
        let calvesHighlight = selectedGroup == MuscleGroup.calves
        // Left calf
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX - 40, y: 330),
            CGPoint(x: centerX - 45, y: 350),
            CGPoint(x: centerX - 40, y: 380),
            CGPoint(x: centerX - 30, y: 380),
            CGPoint(x: centerX - 25, y: 350)
        ], highlight: calvesHighlight)
        
        // Right calf
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX + 40, y: 330),
            CGPoint(x: centerX + 45, y: 350),
            CGPoint(x: centerX + 40, y: 380),
            CGPoint(x: centerX + 30, y: 380),
            CGPoint(x: centerX + 25, y: 350)
        ], highlight: calvesHighlight)
        
        return path
    }
    
    private func addMuscleGroup(to path: inout Path, points: [CGPoint], highlight: Bool) {
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addQuadCurve(
                to: points[i],
                control: CGPoint(
                    x: (points[i].x + points[i-1].x) / 2,
                    y: (points[i].y + points[i-1].y) / 2
                )
            )
        }
        path.addQuadCurve(
            to: points[0],
            control: CGPoint(
                x: (points[0].x + points[points.count-1].x) / 2,
                y: (points[0].y + points[points.count-1].y) / 2
            )
        )
    }
}

struct BackMuscleMap: Shape {
    let selectedGroup: MuscleGroup?
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        
        // Head (for reference)
        path.addEllipse(in: CGRect(x: centerX - 25, y: 10, width: 50, height: 60))
        
        // Traps
        let trapsHighlight = selectedGroup == MuscleGroup.traps
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX - 50, y: 70),
            CGPoint(x: centerX, y: 85),
            CGPoint(x: centerX + 50, y: 70),
            CGPoint(x: centerX + 40, y: 100),
            CGPoint(x: centerX, y: 110),
            CGPoint(x: centerX - 40, y: 100)
        ], highlight: trapsHighlight)
        
        // Rear Deltoids
        let rearDeltsHighlight = selectedGroup == MuscleGroup.backShoulders
        // Left rear delt
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX - 40, y: 85),
            CGPoint(x: centerX - 65, y: 90),
            CGPoint(x: centerX - 70, y: 100),
            CGPoint(x: centerX - 65, y: 110),
            CGPoint(x: centerX - 50, y: 105)
        ], highlight: rearDeltsHighlight)
        
        // Right rear delt
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX + 40, y: 85),
            CGPoint(x: centerX + 65, y: 90),
            CGPoint(x: centerX + 70, y: 100),
            CGPoint(x: centerX + 65, y: 110),
            CGPoint(x: centerX + 50, y: 105)
        ], highlight: rearDeltsHighlight)
        
        // Lats
        let latsHighlight = selectedGroup == MuscleGroup.lats
        // Left lat
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX - 40, y: 110),
            CGPoint(x: centerX - 60, y: 130),
            CGPoint(x: centerX - 65, y: 160),
            CGPoint(x: centerX - 50, y: 180),
            CGPoint(x: centerX - 30, y: 150)
        ], highlight: latsHighlight)
        
        // Right lat
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX + 40, y: 110),
            CGPoint(x: centerX + 60, y: 130),
            CGPoint(x: centerX + 65, y: 160),
            CGPoint(x: centerX + 50, y: 180),
            CGPoint(x: centerX + 30, y: 150)
        ], highlight: latsHighlight)
        
        // Triceps
        let tricepsHighlight = selectedGroup == MuscleGroup.triceps
        // Left tricep
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX - 65, y: 110),
            CGPoint(x: centerX - 75, y: 130),
            CGPoint(x: centerX - 70, y: 150),
            CGPoint(x: centerX - 60, y: 155),
            CGPoint(x: centerX - 55, y: 130)
        ], highlight: tricepsHighlight)
        
        // Right tricep
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX + 65, y: 110),
            CGPoint(x: centerX + 75, y: 130),
            CGPoint(x: centerX + 70, y: 150),
            CGPoint(x: centerX + 60, y: 155),
            CGPoint(x: centerX + 55, y: 130)
        ], highlight: tricepsHighlight)
        
        // Glutes
        let glutesHighlight = selectedGroup == MuscleGroup.glutes
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX - 40, y: 200),
            CGPoint(x: centerX, y: 210),
            CGPoint(x: centerX + 40, y: 200),
            CGPoint(x: centerX + 45, y: 230),
            CGPoint(x: centerX, y: 240),
            CGPoint(x: centerX - 45, y: 230)
        ], highlight: glutesHighlight)
        
        // Hamstrings
        let hamstringsHighlight = selectedGroup == MuscleGroup.hamstrings
        // Left hamstring
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX - 30, y: 240),
            CGPoint(x: centerX - 45, y: 280),
            CGPoint(x: centerX - 40, y: 320),
            CGPoint(x: centerX - 25, y: 330),
            CGPoint(x: centerX - 20, y: 280)
        ], highlight: hamstringsHighlight)
        
        // Right hamstring
        addMuscleGroup(to: &path, points: [
            CGPoint(x: centerX + 30, y: 240),
            CGPoint(x: centerX + 45, y: 280),
            CGPoint(x: centerX + 40, y: 320),
            CGPoint(x: centerX + 25, y: 330),
            CGPoint(x: centerX + 20, y: 280)
        ], highlight: hamstringsHighlight)
        
        return path
    }
    
    private func addMuscleGroup(to path: inout Path, points: [CGPoint], highlight: Bool) {
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addQuadCurve(
                to: points[i],
                control: CGPoint(
                    x: (points[i].x + points[i-1].x) / 2,
                    y: (points[i].y + points[i-1].y) / 2
                )
            )
        }
        path.addQuadCurve(
            to: points[0],
            control: CGPoint(
                x: (points[0].x + points[points.count-1].x) / 2,
                y: (points[0].y + points[points.count-1].y) / 2
            )
        )
    }
} 
