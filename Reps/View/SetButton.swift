import SwiftUI
import UIKit

struct SetButton: View {
    @Binding var showCheckmark: Bool
    @Binding var setCount: Int
    @State var fb = false
    @GestureState var topG = false
    var action: () -> Void // Closure to perform the action

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
            .overlay(
                Circle()
                    .trim(from: 0, to: topG ? 1 : 0)
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotation(.degrees(-90))
            )
            .contentShape(Circle().inset(by: -15))
            .animation(.easeInOut.speed(0.8), value: topG)
            .scaleEffect(topG ? 1.1 : 1)
            .gesture(
                LongPressGesture(minimumDuration: 0.4, maximumDistance: 1)
                    .updating($topG) { currentState, gestureState, _ in
                        gestureState = currentState
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            showCheckmark = true
                        }

                        // Trigger haptic feedback
                        feedbackGenerator.impactOccurred()

                        // Call the closure to perform the action
                        action()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                showCheckmark = false
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
