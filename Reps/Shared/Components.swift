import SwiftUI
// MARK: - Shared Components

public struct StatRow: View {
    let label: String
    let value: String
    
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    public var body: some View {
        HStack {
            Text(label + ":")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

// Helper functions that might be needed across views
public struct Formatter {
    public static func decimal(_ value: Double) -> String {
        value == floor(value) ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
    
    public static func time(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    public static func date(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

public struct GraphPoint: Identifiable {
    public let id = UUID()
    public let date: Date
    public let value: Double
    public let label: String
    
    public init(date: Date, value: Double, label: String) {
        self.date = date
        self.value = value
        self.label = label
    }
}

public struct ExerciseGraph: View {
    let title: String
    let points: [GraphPoint]
    let maxValue: Double
    let color: Color
    @State private var selectedPoint: GraphPoint?
    @State private var showTooltip = false
    @State private var tooltipPosition: CGPoint = .zero
    
    public init(title: String, points: [GraphPoint], color: Color = .green) {
        self.title = title
        self.points = points
        self.maxValue = points.map { $0.value }.max() ?? 0
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                if let selectedPoint = selectedPoint {
                    Spacer()
                    Text(selectedPoint.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    // Grid lines
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<5) { i in
                            Divider()
                                .background(Color.gray.opacity(0.3))
                                .frame(height: 1)
                                .offset(y: geometry.size.height / 4 * CGFloat(i))
                        }
                    }
                    
                    // Graph line
                    Path { path in
                        guard let firstPoint = points.first else { return }
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let xStep = width / CGFloat(points.count - 1)
                        
                        path.move(to: CGPoint(
                            x: 0,
                            y: height - (height * CGFloat(firstPoint.value) / CGFloat(maxValue))
                        ))
                        
                        for (index, point) in points.enumerated() {
                            path.addLine(to: CGPoint(
                                x: CGFloat(index) * xStep,
                                y: height - (height * CGFloat(point.value) / CGFloat(maxValue))
                            ))
                        }
                    }
                    .stroke(color, lineWidth: 2)
                    
                    // Interactive points with larger touch targets
                    ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let xStep = width / CGFloat(points.count - 1)
                        let x = CGFloat(index) * xStep
                        let y = height - (height * CGFloat(point.value) / CGFloat(maxValue))
                        
                        Circle()
                            .fill(selectedPoint?.id == point.id ? color : color.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(color, lineWidth: 2)
                            )
                            .position(x: x, y: y)
                            .overlay(
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 44, height: 44)
                                    .position(x: x, y: y)
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if selectedPoint?.id == point.id {
                                        selectedPoint = nil
                                    } else {
                                        selectedPoint = point
                                        tooltipPosition = CGPoint(x: x, y: y)
                                    }
                                }
                            }
                    }
                    
                    // Date labels
                    if points.count > 1 {
                        HStack {
                            Text(Formatter.date(points.first?.date ?? Date()))
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(Formatter.date(points.last?.date ?? Date()))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .offset(y: geometry.size.height + 8)
                    }
                }
            }
            .frame(height: 200)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    selectedPoint = nil
                }
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}
