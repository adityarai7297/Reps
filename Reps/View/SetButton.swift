import SwiftUI
import UIKit

struct SetButton: View {
    @Binding var showCheckmark: Bool
    @Binding var setCount: Int
    @GestureState var topG = false
    var action: () -> Void // Closure to perform the action
    @State private var showTrimAnimation = false // State to control the trim effect
    @State private var isRotationActive = false // Track when the rotation starts
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
                
                // Circular trim animation
                if showTrimAnimation {
                    CircularTrimView(isRotationActive: $isRotationActive)
                        .frame(width: 92, height: 92) // Match the button size
                        .transition(.opacity)
                }
            }
            .gesture(
                LongPressGesture(minimumDuration: 0.2)
                    .updating($topG) { currentState, gestureState, _ in
                        gestureState = currentState
                    }
                    .onEnded { _ in
                        // Reset the rotation state on each tap
                        isRotationActive = false
                        
                        // Show the trim animation
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            showTrimAnimation = true
                        }

                        // Delay actions slightly, but not dependent on rotation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            // On the first tap of the day, initialize everything properly
                            if isFirstTap {
                                // Ensure the rotation flag is now active
                                isRotationActive = true
                                isFirstTap = false // Reset flag to allow subsequent sets to sync normally
                            }

                            // Trigger haptic feedback right after the rotation animation starts
                            feedbackGenerator.impactOccurred()

                            // Update the set count first
                            action()

                            // Show checkmark after setCount update
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                showCheckmark = true
                            }

                            // Gradually reverse the animation after the checkmark shows
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    showCheckmark = false
                                    showTrimAnimation = false // Hide circular trim
                                }
                            }
                        }
                    }
            )
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: topG)
        }
        .onAppear {
            feedbackGenerator.prepare()
        }
    }
}

struct CircularTrimView: View {
    @Binding var isRotationActive: Bool // Binding to notify when the rotation starts
    @State private var trimEnd: CGFloat = 0
    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .trim(from: 0, to: trimEnd) // Control the trim from 0 to 1
            .stroke(Color.black, lineWidth: 4) // Black color and thicker stroke
            .rotationEffect(.degrees(rotation)) // Rotate the trim for a dynamic effect
            .onAppear {
                // Start clockwise animation
                withAnimation(Animation.easeInOut(duration: 0.6)) {
                    trimEnd = 1 // Animate the trim to complete the circle
                    rotation = 90 // Rotate the circle clockwise
                }

                // Mark rotation as active after animation starts
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isRotationActive = true
                }

                // Reverse (counterclockwise) rotation after trim reaches 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(Animation.easeInOut(duration: 0.35)) {
                        trimEnd = 0 // Snap back by animating the trim back to 0
                        rotation = 0 // Rotate counterclockwise
                    }
                }
            }
    }
}
