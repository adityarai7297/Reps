import SwiftUI
import UIKit

struct SetButton: View {
    @State private var buttonScale: CGFloat = 1.0
    @Binding var showCheckmark: Bool
    @Binding var setCount: Int
    @EnvironmentObject var themeManager: ThemeManager
    let action: () -> Void
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        VStack(spacing: 10) {
            // Success Message Above the Set Button
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

            // Set Button
            ZStack {
                Circle()
                    .stroke(themeManager.textColor, lineWidth: 0.5)
                    .frame(width: 92, height: 92)

                Text("SET")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.textColor)
            }
            .scaleEffect(buttonScale)
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
        feedbackGenerator.impactOccurred()
        buttonScale = 1.2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            buttonScale = 1.0
        }

        action()

        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
            showCheckmark = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCheckmark = false
            }
        }
    }
}
