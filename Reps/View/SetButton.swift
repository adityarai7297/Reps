import SwiftUI
import UIKit

struct SetButton: View {
    @Binding var showCheckmark: Bool
    @Binding var setCount: Int
    var action: () -> Void // Closure to perform the action
    @State private var isFirstTap = true // Track if it's the first tap of the day
    @State private var buttonScale: CGFloat = 1.0 // State variable for button scaling animation

    // Haptic feedback generator
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    var body: some View {
        VStack(spacing: 10) {
            // **Success Message Above the Set Button**
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
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: showCheckmark)
            }

            // **Set Button**
            ZStack {
                Circle()
                    .stroke(lineWidth: 0.5)
                    .frame(width: 92, height: 92)

                Text("SET")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .scaleEffect(buttonScale) // Apply scaling animation
            .onTapGesture {
                performAction()
            }
            .highPriorityGesture(
                LongPressGesture(minimumDuration: 0.2)
                    .onEnded { _ in
                        performAction()
                    }
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.5), value: buttonScale)
        }
        .onAppear {
            feedbackGenerator.prepare()
        }
    }

    private func performAction() {
        // Trigger haptic feedback
        feedbackGenerator.impactOccurred()

        // Start the button scaling animation
        buttonScale = 1.2 // Expand the button

        // Return the button to its original size after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            buttonScale = 1.0 // Shrink the button back
        }

        // Update the set count
        action()

        // Show checkmark after setCount update
        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
            showCheckmark = true
        }

        // Gradually reverse the animation after the checkmark shows
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCheckmark = false
            }
        }
    }
}
