import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
    var containsCalendar: Bool = false
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    func addMessage(_ text: String, isUser: Bool, containsCalendar: Bool = false) {
        let message = ChatMessage(text: text, isUser: isUser, timestamp: Date(), containsCalendar: containsCalendar)
        messages.append(message)
    }
    
    func askAboutConsistency() {
        addMessage("What does my consistency look like?", isUser: true)
    }
} 