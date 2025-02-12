import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    @Binding var selectedDate: Date?
    let workoutData: [Date: Int]
    @State private var isTyping = false
    @State private var isAppearing = false
    @State private var isPressed = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isUser {
                // System avatar with animated gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "brain")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .scaleEffect(isTyping ? 1.1 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isTyping)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: message.containsCalendar ? 24 : 8) {
                if message.containsCalendar {
                    GitHubStyleCalendarView(selectedDate: $selectedDate, workoutData: workoutData)
                        .frame(height: 180)
                        .padding(.vertical, 16)
                        .padding(.bottom, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.3))
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                }
                
                // Message bubble with dynamic gradient or glass effect
                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .foregroundColor(message.isUser ? .black.opacity(0.8) : .white)
                    .background(
                        Group {
                            if message.isUser {
                                Color.white.opacity(0.9)
                            } else {
                                Color.gray.opacity(0.3)
                                    .background(.ultraThinMaterial)
                            }
                        }
                    )
                    .clipShape(BubbleShape(isUser: message.isUser))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .scaleEffect(isPressed ? 0.97 : 1.0)
                    .animation(.spring(response: 0.3), value: isPressed)
                    .onTapGesture {
                        withAnimation {
                            isPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isPressed = false
                            }
                        }
                    }
            }
            .frame(maxWidth: message.containsCalendar ? .infinity : UIScreen.main.bounds.width * 0.7, alignment: message.isUser ? .trailing : .leading)
            .opacity(isAppearing ? 1 : 0)
            .offset(y: isAppearing ? 0 : 20)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, message.containsCalendar ? 16 : 8)
        .onAppear {
            if !message.isUser {
                // Simulate typing animation for system messages
                isTyping = true
                withAnimation(.easeOut(duration: 0.3)) {
                    isAppearing = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isTyping = false
                    }
                }
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isAppearing = true
                }
            }
        }
    }
}

// Custom bubble shape for chat messages
struct BubbleShape: Shape {
    let isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let bezierPath = UIBezierPath()
        let cornerRadius: CGFloat = 16
        
        if isUser {
            bezierPath.move(to: CGPoint(x: width - cornerRadius, y: height))
            bezierPath.addLine(to: CGPoint(x: cornerRadius, y: height))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height - cornerRadius),
                              controlPoint1: CGPoint(x: cornerRadius/2, y: height),
                              controlPoint2: CGPoint(x: 0, y: height - cornerRadius/2))
            bezierPath.addLine(to: CGPoint(x: 0, y: cornerRadius))
            bezierPath.addCurve(to: CGPoint(x: cornerRadius, y: 0),
                              controlPoint1: CGPoint(x: 0, y: cornerRadius/2),
                              controlPoint2: CGPoint(x: cornerRadius/2, y: 0))
            bezierPath.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
            bezierPath.addCurve(to: CGPoint(x: width, y: cornerRadius),
                              controlPoint1: CGPoint(x: width - cornerRadius/2, y: 0),
                              controlPoint2: CGPoint(x: width, y: cornerRadius/2))
            bezierPath.addLine(to: CGPoint(x: width, y: height - cornerRadius))
            bezierPath.addCurve(to: CGPoint(x: width - cornerRadius, y: height),
                              controlPoint1: CGPoint(x: width, y: height - cornerRadius/2),
                              controlPoint2: CGPoint(x: width - cornerRadius/2, y: height))
        } else {
            bezierPath.move(to: CGPoint(x: cornerRadius, y: height))
            bezierPath.addLine(to: CGPoint(x: width - cornerRadius, y: height))
            bezierPath.addCurve(to: CGPoint(x: width, y: height - cornerRadius),
                              controlPoint1: CGPoint(x: width - cornerRadius/2, y: height),
                              controlPoint2: CGPoint(x: width, y: height - cornerRadius/2))
            bezierPath.addLine(to: CGPoint(x: width, y: cornerRadius))
            bezierPath.addCurve(to: CGPoint(x: width - cornerRadius, y: 0),
                              controlPoint1: CGPoint(x: width, y: cornerRadius/2),
                              controlPoint2: CGPoint(x: width - cornerRadius/2, y: 0))
            bezierPath.addLine(to: CGPoint(x: cornerRadius, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 0, y: cornerRadius),
                              controlPoint1: CGPoint(x: cornerRadius/2, y: 0),
                              controlPoint2: CGPoint(x: 0, y: cornerRadius/2))
            bezierPath.addLine(to: CGPoint(x: 0, y: height - cornerRadius))
            bezierPath.addCurve(to: CGPoint(x: cornerRadius, y: height),
                              controlPoint1: CGPoint(x: 0, y: height - cornerRadius/2),
                              controlPoint2: CGPoint(x: cornerRadius/2, y: height))
        }
        
        bezierPath.close()
        return Path(bezierPath.cgPath)
    }
}

struct ChatInputField: View {
    @Binding var text: String
    let onSubmit: () -> Void
    @Binding var showTopics: Bool
    @ObservedObject var chatViewModel: ChatViewModel
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isFocused: Bool
    
    var body: some View {
        KeyboardAdaptiveView {
            VStack(spacing: 0) {
                // Text Input with dynamic background
                CustomTextField(text: $text, onSubmit: {
                    if !text.isEmpty {
                        onSubmit()
                        text = ""
                        isFocused = false
                    }
                })
                    .focused($isFocused)
                    .frame(height: 40)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.3))
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.bottom, 8)
            }
            .background(.ultraThinMaterial)
        }
    }
}

struct KeyboardAdaptiveView<Content: View>: View {
    let content: () -> Content
    @State private var keyboardHeight: CGFloat = 0
    @Environment(\.scenePhase) var scenePhase
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(.bottom, keyboardHeight)
            .onAppear {
                setupKeyboardNotifications()
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase != .active {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            keyboardHeight = keyboardFrame.height
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
        }
    }
}

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    let onSubmit: () -> Void
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = "Ask me anything..."
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.returnKeyType = .send
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        // Preload text input session
        DispatchQueue.main.async {
            _ = textField.becomeFirstResponder()
            textField.resignFirstResponder()
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        let onSubmit: () -> Void
        
        init(text: Binding<String>, onSubmit: @escaping () -> Void) {
            _text = text
            self.onSubmit = onSubmit
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text,
               let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                self.text = updatedText
            }
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if !text.isEmpty {
                onSubmit()
                text = ""
                textField.resignFirstResponder()
            }
            return true
        }
    }
}

struct TopicCard: View {
    let topic: ChatTopic
    @State private var isExpanded = false
    @State private var animateGradient = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Topic Header
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: topic.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.yellow.opacity(0.8))
                        .rotationEffect(.degrees(isExpanded ? 360 : 0))
                    
                    Text(topic.title)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.6))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
} 


struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        ChatBubble(
            message: ChatMessage(
                text: "Hello, how are you?",
                isUser: false,
                timestamp: Date()
            ),
            selectedDate: .constant(Date()),
            workoutData: [:]
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.black)
    }
}
