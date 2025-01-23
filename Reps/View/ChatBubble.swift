import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    @Binding var selectedDate: Date?
    let workoutData: [Date: Int]
    
    var body: some View {
        HStack {
            if !message.isUser {
                Spacer()
            }
            
            VStack {
                if message.containsCalendar {
                    GitHubStyleCalendarView(selectedDate: $selectedDate, workoutData: workoutData)
                        .frame(height: 180)
                        .padding(.vertical, 20)
                }
                
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(message.isUser ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            .frame(maxWidth: message.containsCalendar ? .infinity : UIScreen.main.bounds.width * 0.7)
            
            if message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
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
        .padding()
        .background(Color.black)
    }
} 