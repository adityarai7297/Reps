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
    @State private var animationProgress: CGFloat = 0
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    public init(title: String, points: [GraphPoint], color: Color = .green) {
        self.title = title
        self.points = points.filter { !$0.value.isNaN } // Filter out NaN values
        self.maxValue = points.map { $0.value }.max() ?? 0
        self.color = color
    }
    
    private func tooltipView(for point: GraphPoint, at position: CGPoint) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Formatter.date(point.date))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
            Text(point.label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.8))
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .position(x: position.x, y: max(position.y - 50, 30))
        .transition(.opacity.combined(with: .scale))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title and selected value
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                if let selectedPoint = selectedPoint {
                    Spacer()
                    Text(selectedPoint.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                        .transition(.opacity)
                }
            }
            
            // Graph area with bottom padding for x-axis labels
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    ZStack(alignment: .topLeading) {
                        // Grid lines with subtle gradient
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(0..<5) { i in
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.gray.opacity(0.2),
                                        Color.gray.opacity(0.1)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(height: 1)
                                .offset(y: geometry.size.height / 4 * CGFloat(i))
                            }
                        }
                        
                        if !points.isEmpty {
                            // Graph area with gradient fill
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let xStep = width / CGFloat(max(points.count - 1, 1))
                                
                                path.move(to: CGPoint(
                                    x: 0,
                                    y: height - (CGFloat(points[0].value) / CGFloat(maxValue)) * height * animationProgress
                                ))
                                
                                for (index, point) in points.enumerated() {
                                    let x = CGFloat(index) * xStep
                                    let y = height - (CGFloat(point.value) / CGFloat(maxValue)) * height * animationProgress
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        let control1 = CGPoint(
                                            x: x - xStep / 2,
                                            y: path.currentPoint?.y ?? y
                                        )
                                        let control2 = CGPoint(
                                            x: x - xStep / 2,
                                            y: y
                                        )
                                        path.addCurve(
                                            to: CGPoint(x: x, y: y),
                                            control1: control1,
                                            control2: control2
                                        )
                                    }
                                }
                                
                                // Add points for gradient fill
                                path.addLine(to: CGPoint(x: width, y: height))
                                path.addLine(to: CGPoint(x: 0, y: height))
                                path.closeSubpath()
                            }
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        color.opacity(0.3),
                                        color.opacity(0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            // Graph line
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let xStep = width / CGFloat(max(points.count - 1, 1))
                                
                                path.move(to: CGPoint(
                                    x: 0,
                                    y: height - (CGFloat(points[0].value) / CGFloat(maxValue)) * height * animationProgress
                                ))
                                
                                for (index, point) in points.enumerated() {
                                    let x = CGFloat(index) * xStep
                                    let y = height - (CGFloat(point.value) / CGFloat(maxValue)) * height * animationProgress
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        let control1 = CGPoint(
                                            x: x - xStep / 2,
                                            y: path.currentPoint?.y ?? y
                                        )
                                        let control2 = CGPoint(
                                            x: x - xStep / 2,
                                            y: y
                                        )
                                        path.addCurve(
                                            to: CGPoint(x: x, y: y),
                                            control1: control1,
                                            control2: control2
                                        )
                                    }
                                }
                            }
                            .stroke(color, lineWidth: 2)
                            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                            
                            // Interactive touch points
                            ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                                let x = CGFloat(index) * (geometry.size.width / CGFloat(max(points.count - 1, 1)))
                                let y = geometry.size.height - (CGFloat(point.value) / CGFloat(maxValue)) * geometry.size.height * animationProgress
                                
                                Circle()
                                    .fill(selectedPoint?.id == point.id ? color : Color.white)
                                    .frame(width: 8, height: 8)
                                    .overlay(
                                        Circle()
                                            .stroke(color, lineWidth: 2)
                                    )
                                    .position(x: x, y: y)
                                    .scaleEffect(selectedPoint?.id == point.id ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3), value: selectedPoint?.id)
                            }
                            
                            // Invisible touch areas for better interaction
                            ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                                let x = CGFloat(index) * (geometry.size.width / CGFloat(max(points.count - 1, 1)))
                                let y = geometry.size.height - (CGFloat(point.value) / CGFloat(maxValue)) * geometry.size.height * animationProgress
                                
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 44, height: 44)
                                    .position(x: x, y: y)
                                    .onTapGesture {
                                        hapticFeedback.impactOccurred()
                                        withAnimation(.spring(response: 0.3)) {
                                            if selectedPoint?.id == point.id {
                                                selectedPoint = nil
                                                tooltipPosition = .zero
                                                showTooltip = false
                                            } else {
                                                selectedPoint = point
                                                tooltipPosition = CGPoint(x: x, y: y)
                                                showTooltip = true
                                            }
                                        }
                                    }
                            }
                            
                            // Tooltip overlay
                            if showTooltip, let selectedPoint = selectedPoint {
                                tooltipView(for: selectedPoint, at: tooltipPosition)
                            }
                        }
                    }
                }
                .frame(height: 180)
                
                // X-axis labels in separate view to prevent clipping
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
                    .padding(.top, 8)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3)) {
                    selectedPoint = nil
                    showTooltip = false
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
