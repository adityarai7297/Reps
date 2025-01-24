import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    @Binding var selectedDate: Date?
    let workoutData: [Date: Int]
    @State private var isTyping = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isUser {
                // System avatar
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "brain")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    )
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: message.containsCalendar ? 16 : 4) {
                if message.containsCalendar {
                    GitHubStyleCalendarView(selectedDate: $selectedDate, workoutData: workoutData)
                        .frame(height: 180)
                        .padding(.vertical, 16)
                        .padding(.bottom, 8)
                }
                
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isUser 
                        ? Color.blue 
                        : Color.gray.opacity(0.3)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .opacity(isTyping ? 0.5 : 1.0)
            }
            .frame(maxWidth: message.containsCalendar ? .infinity : UIScreen.main.bounds.width * 0.7, alignment: message.isUser ? .trailing : .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, message.containsCalendar ? 12 : 4)
        .onAppear {
            if !message.isUser {
                // Simulate typing animation for system messages
                isTyping = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isTyping = false
                    }
                }
            }
        }
    }
}

struct ChatInputField: View {
    @Binding var text: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask me anything...", text: $text)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(20)
                .foregroundColor(.white)
            
            Button(action: onSubmit) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black)
    }
} 