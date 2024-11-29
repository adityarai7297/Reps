import SwiftUI

struct VerticalPager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let contentAtIndex: (Int) -> Content

    @GestureState private var dragOffset: CGFloat = 0
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
    @State private var velocityTracker: CGFloat = 0
    @State private var bounceOffset: CGFloat = 0
    
    // Constants for fine-tuning
    private let velocityThreshold: CGFloat = 300
    private let dragThreshold: CGFloat = 100
    private let springResponse: Double = 0.35
    private let springDamping: Double = 0.8
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            
            ZStack {
                ForEach((max(0, currentIndex - 2)...min(pageCount - 1, currentIndex + 2)), id: \.self) { index in
                    contentAtIndex(index)
                        .frame(width: geometry.size.width, height: height)
                        .offset(y: CGFloat(index - currentIndex) * height + dragOffset + bounceOffset)
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .updating($dragOffset) { value, state, _ in
                        let verticalDrag = abs(value.translation.height)
                        let horizontalDrag = abs(value.translation.width)
                        if verticalDrag > horizontalDrag && verticalDrag > 50 {
                            state = value.translation.height
                            velocityTracker = value.velocity.height
                        }
                    }
                    .onEnded { value in
                        let dragDistance = value.translation.height
                        let velocity = value.predictedEndLocation.y - value.location.y
                        
                        let verticalDrag = abs(dragDistance)
                        let horizontalDrag = abs(value.translation.width)
                        guard verticalDrag > horizontalDrag && verticalDrag > 50 else { return }
                        
                        impactFeedback.prepare()
                        
                        if velocity < -velocityThreshold || dragDistance < -dragThreshold {
                            if currentIndex < pageCount - 1 {
                                impactFeedback.impactOccurred()
                                withAnimation(.spring(response: springResponse, dampingFraction: springDamping)) {
                                    currentIndex += 1
                                    bounceOffset = 0
                                }
                            } else {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                    bounceOffset = 20
                                }
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.5).delay(0.1)) {
                                    bounceOffset = 0
                                }
                            }
                        } else if velocity > velocityThreshold || dragDistance > dragThreshold {
                            if currentIndex > 0 {
                                impactFeedback.impactOccurred()
                                withAnimation(.spring(response: springResponse, dampingFraction: springDamping)) {
                                    currentIndex -= 1
                                    bounceOffset = 0
                                }
                            } else {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                    bounceOffset = -20
                                }
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.5).delay(0.1)) {
                                    bounceOffset = 0
                                }
                            }
                        } else {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                bounceOffset = 0
                            }
                        }
                    }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}
