import SwiftUI

struct SetButton: View {
    @Binding var showCheckmark: Bool
    @Binding var setCount: Int
    @GestureState private var isPressing = false
    @State private var progress: CGFloat = 0.0
    var action: () -> Void

    // Haptic feedback generator
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    var body: some View {
        VStack(spacing: 10) {
            // Success Message
            if showCheckmark {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.green)
                        .frame(width: 132, height: 50)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                        
                        Text("Added!")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }
                .transition(.scale)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: showCheckmark)
            }

            // **Set Button with Progress Overlay**
            ZStack {
                // Original Set Button Design
                Circle()
                    .stroke(lineWidth: 0.5)
                    .frame(width: 92, height: 92)

                Text("SET")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                // Circular Progress Overlay
                Circle()
                    .trim(from: 0, to: progress)  // Progress based on gesture
                    .stroke(Color.blue, lineWidth: 6) // Visible stroke for progress
                    .frame(width: 92, height: 92)
                    .rotationEffect(.degrees(-90))  // Start progress from top
                    .opacity(isPressing ? 1.0 : 0.0) // Show during press only
            }
            .gesture(
                LongPressGesture(minimumDuration: 0.4)
                    .updating($isPressing) { currentState, gestureState, _ in
                        gestureState = currentState
                        if currentState {
                            withAnimation(.linear(duration: 0.4)) {
                                progress = 1.0 // Animate progress
                            }
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            showCheckmark = true
                        }

                        // Trigger haptic feedback
                        feedbackGenerator.impactOccurred()

                        // Perform action
                        action()

                        // Reset progress and checkmark after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                showCheckmark = false
                                progress = 0.0 // Reset progress
                            }
                        }
                    }
            )
            .animation(.easeInOut, value: isPressing)
        }
        .onAppear {
            feedbackGenerator.prepare()
        }
    }
}
