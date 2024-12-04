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
    
    public static func date(_ date: Date, format: DateFormat = .medium) -> String {
        let formatter = DateFormatter()
        switch format {
            case .medium:
                formatter.dateFormat = "MMM d, yyyy"
            case .monthYear:
                formatter.dateFormat = "MMM yyyy"
            case .weekRange:
                let calendar = Calendar.current
                let endOfWeek = calendar.date(byAdding: .day, value: 6, to: date) ?? date
                formatter.dateFormat = "MMM d"
                let startStr = formatter.string(from: date)
                let endStr = formatter.string(from: endOfWeek)
                return "\(startStr) - \(endStr)"
        }
        return formatter.string(from: date)
    }
    
    public enum DateFormat {
        case medium
        case monthYear
        case weekRange
    }
}

public enum TimeRange: String, CaseIterable {
    case week = "W"
    case month = "M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case year = "Y"
    case all = "All"
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
    let timeRange: TimeRange
    @State private var selectedPoint: GraphPoint?
    @State private var animationProgress: CGFloat = 0
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    public init(title: String, points: [GraphPoint], color: Color = .green, timeRange: TimeRange = .week) {
        self.title = title
        self.points = points.filter { !$0.value.isNaN }
        self.maxValue = points.map { $0.value }.max() ?? 0
        self.color = color
        self.timeRange = timeRange
    }
    
    private func dateFormat(for point: GraphPoint) -> String {
        switch timeRange {
            case .week:
                return Formatter.date(point.date)
            case .month, .threeMonths:
                return Formatter.date(point.date, format: .weekRange)
            case .sixMonths, .year, .all:
                return Formatter.date(point.date, format: .monthYear)
        }
    }
    
    private func tooltipView(for point: GraphPoint, index: Int, totalPoints: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(point.label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            Text(dateFormat(for: point))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.8))
                .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .offset(x: index == 0 ? 40 : (index == totalPoints - 1 ? -40 : 0))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            // Graph area
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    // Grid lines
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
                        
                        // Points and tooltips
                        ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                            let x = CGFloat(index) * (geometry.size.width / CGFloat(max(points.count - 1, 1)))
                            let y = geometry.size.height - (CGFloat(point.value) / CGFloat(maxValue)) * geometry.size.height * animationProgress
                            
                            ZStack {
                                // Point
                                Circle()
                                    .fill(selectedPoint?.id == point.id ? color : .white)
                                    .frame(width: 12, height: 12)
                                    .overlay(Circle().stroke(color, lineWidth: 2))
                                    .onTapGesture {
                                        hapticFeedback.impactOccurred()
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedPoint = selectedPoint?.id == point.id ? nil : point
                                        }
                                    }
                                
                                // Tooltip
                                if selectedPoint?.id == point.id {
                                    tooltipView(for: point, index: index, totalPoints: points.count)
                                        .offset(y: y < 60 ? 25 : -45)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .position(x: x, y: y)
                        }
                    }
                }
            }
            .frame(height: 180)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    selectedPoint = nil
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            }
            
            // X-axis labels
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
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
