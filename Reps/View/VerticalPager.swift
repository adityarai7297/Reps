import SwiftUI

struct VerticalPager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let contentAtIndex: (Int) -> Content

    @GestureState private var dragOffset: CGFloat = 0
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

    // Add a parameter for drag threshold
    var dragThreshold: CGFloat = 50 // Default value, adjust as needed

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height

            ZStack {
                ForEach((currentIndex - 1)...(currentIndex + 1), id: \.self) { index in
                    if index >= 0 && index < pageCount {
                        contentAtIndex(index)
                            .frame(width: geometry.size.width, height: height)
                            .offset(y: CGFloat(index - currentIndex) * height + dragOffset)
                    }
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded {
                        value in
                        let dragDistance = value.translation.height
                        let predictedEndOffset = value.predictedEndTranslation.height
                        let dragVelocity = value.velocity.height
                        let threshold = dragThreshold

                        if dragDistance < -threshold || dragVelocity < -500 {
                            if currentIndex < pageCount - 1 {
                                impactFeedback.impactOccurred()
                                currentIndex += 1
                            }
                        } else if dragDistance > threshold || dragVelocity > 500 {
                            if currentIndex > 0 {
                                impactFeedback.impactOccurred()
                                currentIndex -= 1
                            }
                        }
                    }
            )
            .animation(.interactiveSpring(), value: dragOffset)
            .animation(.interactiveSpring(), value: currentIndex)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
