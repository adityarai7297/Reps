
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
