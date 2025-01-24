import SwiftUI

struct TextInputPreloader: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            let textField = UITextField()
            view.addSubview(textField)
            textField.becomeFirstResponder()
            DispatchQueue.main.async {
                textField.resignFirstResponder()
                textField.removeFromSuperview()
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

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
        .padding(.vertical, 8)
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
    @FocusState private var isTextFieldFocused: Bool
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(spacing: 0) {
            // Hidden preloader
            TextInputPreloader()
                .frame(width: 0, height: 0)
            
            HStack(spacing: 12) {
                TextField("Ask me anything...", text: $text)
                    .focused($isTextFieldFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isTextFieldFocused ? Color.blue : Color.clear, lineWidth: 1.5)
                            )
                    )
                    .foregroundColor(.white)
                    .onChange(of: isTextFieldFocused) { _, newValue in
                        if newValue {
                            impactFeedback.prepare()
                            impactFeedback.impactOccurred(intensity: 0.7)
                        }
                    }
                    .onAppear {
                        UITextField.appearance().tintColor = .systemBlue
                    }
                    .submitLabel(.send)
                    .onSubmit {
                        if !text.isEmpty {
                            onSubmit()
                        }
                    }
                
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
} 