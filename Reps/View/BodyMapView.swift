import SwiftUI
import SwiftData

struct BodyMapView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExerciseHistory.timestamp, order: .reverse) private var exerciseHistories: [ExerciseHistory]
    @Query private var exercises: [Exercise]
    
    private var last10DaysExercises: [(Date, [ExerciseHistory])] {
        let calendar = Calendar.current
        let today = Date()
        let last10Days = (0..<10).compactMap { days in
            calendar.date(byAdding: .day, value: -days, to: today)
        }
        
        return last10Days.map { date in
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let dayExercises = exerciseHistories.filter { history in
                history.timestamp >= startOfDay && history.timestamp < endOfDay
            }
            return (startOfDay, dayExercises)
        }
    }
    
    private func getMuscleGroups(for exerciseName: String) -> [MuscleGroup] {
        if let exercise = exercises.first(where: { $0.name == exerciseName }) {
            return exercise.targetedMuscleGroups
        }
        return []
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(last10DaysExercises, id: \.0) { date, histories in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(formattedDate(date))
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                if histories.isEmpty {
                                    Text("No exercises")
                                        .foregroundColor(.gray)
                                        .italic()
                                } else {
                                    ForEach(histories) { history in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(history.exerciseName)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            let muscleGroups = getMuscleGroups(for: history.exerciseName)
                                            if !muscleGroups.isEmpty {
                                                FlowLayout(alignment: .leading, spacing: 8) {
                                                    ForEach(muscleGroups, id: \.self) { muscle in
                                                        Text(muscle.rawValue)
                                                            .font(.system(size: 12))
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(Color.white.opacity(0.2))
                                                            .cornerRadius(8)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            if date != last10DaysExercises.last?.0 {
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Recent Exercises")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? 0,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            let point = result.points[index]
            subview.place(at: CGPoint(x: point.x + bounds.minX, y: point.y + bounds.minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var points: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, alignment: HorizontalAlignment, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var lineItems: [(CGSize, Int)] = []
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && !lineItems.isEmpty {
                    // Place current line
                    let xOffset = alignment == .trailing ? (maxWidth - currentX + spacing) : 0
                    for (itemSize, itemIndex) in lineItems {
                        points.append(CGPoint(x: xOffset + currentX - itemSize.width - spacing, y: currentY))
                        currentX -= itemSize.width + spacing
                    }
                    
                    // Move to next line
                    currentY += lineHeight + spacing
                    currentX = size.width + spacing
                    lineHeight = size.height
                    lineItems = [(size, index)]
                } else {
                    currentX += size.width + spacing
                    lineHeight = max(lineHeight, size.height)
                    lineItems.append((size, index))
                }
            }
            
            // Place remaining line
            let xOffset = alignment == .trailing ? (maxWidth - currentX + spacing) : 0
            for (itemSize, itemIndex) in lineItems {
                points.append(CGPoint(x: xOffset + currentX - itemSize.width - spacing, y: currentY))
                currentX -= itemSize.width + spacing
            }
            
            size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
} 
