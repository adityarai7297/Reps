import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
    var containsCalendar: Bool = false
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.isUser == rhs.isUser &&
        lhs.timestamp == rhs.timestamp &&
        lhs.containsCalendar == rhs.containsCalendar
    }
}

struct ChatTopic: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var topics: [ChatTopic] = [
        ChatTopic(
            title: "Workout Analysis",
            icon: "chart.bar.fill"
        ),
        ChatTopic(
            title: "Exercise Guidance",
            icon: "figure.strengthtraining.traditional"
        ),
        ChatTopic(
            title: "Goal Setting",
            icon: "target"
        )
    ]
    
    func addMessage(_ text: String, isUser: Bool, containsCalendar: Bool = false) {
        let message = ChatMessage(
            text: text,
            isUser: isUser,
            timestamp: Date(),
            containsCalendar: containsCalendar
        )
        messages.append(message)
    }
    
    func askAboutConsistency() {
        addMessage("What does my consistency look like?", isUser: true)
    }
} 