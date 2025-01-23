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
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    public static func dateWithFormat(_ date: Date, format: DateFormat) -> String {
        let formatter = DateFormatter()
        switch format {
            case .medium:
                formatter.dateFormat = "EEEE, MMM d, yyyy"
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
