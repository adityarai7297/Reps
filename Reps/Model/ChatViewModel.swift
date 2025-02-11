import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var topics: [ChatTopic] = [
        ChatTopic(
            title: "Workout Analysis",
            icon: "chart.bar.fill",
            suggestedQuestions: [
                "How's my consistency looking?",
                "What's my most frequent exercise?",
                "Show me my progress over time"
            ]
        ),
        ChatTopic(
            title: "Exercise Guidance",
            icon: "figure.strengthtraining.traditional",
            suggestedQuestions: [
                "What exercises should I do today?",
                "How can I improve my form?",
                "Suggest a workout routine"
            ]
        ),
        ChatTopic(
            title: "Goal Setting",
            icon: "target",
            suggestedQuestions: [
                "Help me set a new goal",
                "Am I on track with my goals?",
                "What should I focus on next?"
            ]
        )
    ]
    
    func addMessage(_ text: String, isUser: Bool, containsCalendar: Bool = false, suggestedQuestions: [String] = []) {
        let message = ChatMessage(
            text: text,
            isUser: isUser,
            timestamp: Date(),
            containsCalendar: containsCalendar,
            suggestedQuestions: suggestedQuestions
        )
        messages.append(message)
    }
    
    func askAboutConsistency() {
        addMessage("What does my consistency look like?", isUser: true)
    }
} 