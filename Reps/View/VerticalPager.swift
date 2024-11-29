import SwiftUI

struct VerticalPager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let contentAtIndex: (Int) -> Content

    @GestureState private var dragOffset: CGFloat = 0
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
    @State private var velocityTracker: CGFloat = 0
    @State private var bounceOffset: CGFloat = 0
    @State private var animatedIndex: CGFloat = 0
    
    // Optimized constants for ultra-smooth animations
    private let velocityThreshold: CGFloat = 150  // Even lower threshold
    private let dragThreshold: CGFloat = 40      // Much lower for instant response
    private let springResponse: Double = 0.25    // Faster response
    private let springDamping: Double = 0.7      // Less damping for quicker movement
    private let bounceAmount: CGFloat = 12       // Smaller bounce for faster recovery
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            
            ZStack {
                ForEach((max(0, currentIndex - 2)...min(pageCount - 1, currentIndex + 2)), id: \.self) { index in
                    contentAtIndex(index)
                        .frame(width: geometry.size.width, height: height)
                        .offset(y: (CGFloat(index) - animatedIndex) * height + dragOffset + bounceOffset)
                }
            }
            .onChange(of: currentIndex) { newIndex in
                withAnimation(.spring(response: springResponse, dampingFraction: springDamping)) {
                    animatedIndex = CGFloat(newIndex)
                }
            }
            .onAppear {
                animatedIndex = CGFloat(currentIndex)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 15, coordinateSpace: .local)  // Lower minimum distance
                    .updating($dragOffset) { value, state, _ in
                        let verticalDrag = abs(value.translation.height)
                        let horizontalDrag = abs(value.translation.width)
                        if verticalDrag > horizontalDrag && verticalDrag > 15 {
                            state = value.translation.height
                            velocityTracker = value.velocity.height
                            impactFeedback.prepare()
                        }
                    }
                    .onEnded { value in
                        let dragDistance = value.translation.height
                        let velocity = value.predictedEndLocation.y - value.location.y
                        
                        let verticalDrag = abs(dragDistance)
                        let horizontalDrag = abs(value.translation.width)
                        guard verticalDrag > horizontalDrag && verticalDrag > 15 else { return }
                        
                        if velocity < -velocityThreshold || dragDistance < -dragThreshold {
                            if currentIndex < pageCount - 1 {
                                currentIndex += 1
                                impactFeedback.impactOccurred(intensity: 0.6)
                            } else {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                    bounceOffset = bounceAmount
                                }
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.1)) {
                                    bounceOffset = 0
                                }
                            }
                        } else if velocity > velocityThreshold || dragDistance > dragThreshold {
                            if currentIndex > 0 {
                                currentIndex -= 1
                                impactFeedback.impactOccurred(intensity: 0.6)
                            } else {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                    bounceOffset = -bounceAmount
                                }
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.1)) {
                                    bounceOffset = 0
                                }
                            }
                        } else {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                bounceOffset = 0
                            }
                        }
                    }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}
