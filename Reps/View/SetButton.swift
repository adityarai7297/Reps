import SwiftUI
import UIKit

struct SetButton: View {
    @Binding var showCheckmark: Bool
    @Binding var setCount: Int
    var action: () -> Void // Closure to perform the action
    @State private var isFirstTap = true // Track if it's the first tap of the day

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
            .onTapGesture {
                // On the first tap of the day, initialize everything properly
                if isFirstTap {
                    isFirstTap = false // Reset flag to allow subsequent sets to sync normally
                }

                // Trigger haptic feedback
                feedbackGenerator.impactOccurred()

                // Update the set count
                action()

                // Show checkmark after setCount update
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    showCheckmark = true
                }

                // Gradually reverse the animation after the checkmark shows
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showCheckmark = false
                    }
                }
            }
            // Removed deprecated .animation modifier here
        }
        .onAppear {
            feedbackGenerator.prepare()
        }
    }
}
