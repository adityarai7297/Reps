import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    @Binding var selectedDate: Date?
    let workoutData: [Date: Int]
    @State private var isTyping = false
    let onQuestionSelected: (String) -> Void
    
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
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: message.containsCalendar ? 24 : 4) {
                if message.containsCalendar {
                    GitHubStyleCalendarView(selectedDate: $selectedDate, workoutData: workoutData)
                        .frame(height: 180)
                        .padding(.vertical, 16)
                        .padding(.bottom, 8)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
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
        .padding(.vertical, message.containsCalendar ? 16 : 8)
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
    @State private var showTopics = false
    @ObservedObject var chatViewModel: ChatViewModel
    let onQuestionSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Hidden preloader
            TextInputPreloader()
                .frame(width: 0, height: 0)
            
            HStack(spacing: 12) {
                // Topics Button
                Button(action: {
                    impactFeedback.impactOccurred()
                    showTopics = true
                }) {
                    Image(systemName: "list.bullet.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
                
                // Text Input
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
                
                // Send Button
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
        .sheet(isPresented: $showTopics) {
            TopicsSheet(chatViewModel: chatViewModel, onQuestionSelected: { question in
                text = question
                showTopics = false
                onSubmit()
            })
        }
    }
}

struct TopicsSheet: View {
    @ObservedObject var chatViewModel: ChatViewModel
    let onQuestionSelected: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(chatViewModel.topics) { topic in
                        VStack(alignment: .leading, spacing: 16) {
                            // Topic Header
                            HStack {
                                Image(systemName: topic.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(.yellow)
                                Text(topic.title)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            
                            // Questions Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(topic.suggestedQuestions, id: \.self) { question in
                                    Button(action: {
                                        onQuestionSelected(question)
                                    }) {
                                        Text(question)
                                            .font(.system(size: 15))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.blue.opacity(0.15))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                    )
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 16)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color.black)
            .navigationTitle("Topics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
} 