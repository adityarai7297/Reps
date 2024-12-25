import SwiftUI

struct VerticalPager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let contentAtIndex: (Int) -> Content
    
    @State private var bounceOffset: CGFloat = 0
    @State private var animatedIndex: CGFloat = 0
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // Optimized constants for instant response
    private let velocityThreshold: CGFloat = 100
    private let springResponse: Double = 0.08
    private let springDamping: Double = 0.7
    private let bounceAmount: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            
            ZStack {
                // Render previous, current, and next views during animation
                ForEach((max(0, currentIndex - 1)...min(pageCount - 1, currentIndex + 1)), id: \.self) { index in
                    contentAtIndex(index)
                        .frame(width: geometry.size.width, height: height)
                        .offset(y: (CGFloat(index) - animatedIndex) * height + bounceOffset)
                        .zIndex(index == currentIndex ? 1 : 0)  // Keep current view on top
                }
            }
            .onChange(of: currentIndex) { oldIndex, newIndex in
                // Provide feedback when reaching first or last element
                if newIndex == 0 || newIndex == pageCount - 1 {
                    impactFeedback.impactOccurred()
                }
                withAnimation(.spring(response: springResponse, dampingFraction: springDamping)) {
                    animatedIndex = CGFloat(newIndex)
                }
            }
            .onAppear {
                animatedIndex = CGFloat(currentIndex)
            }
            .gesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onEnded { value in
                        let verticalDrag = abs(value.translation.height)
                        let horizontalDrag = abs(value.translation.width)
                        guard verticalDrag > horizontalDrag && verticalDrag > 10 else { return }
                        
                        if value.translation.height < 0 {  // Swipe up
                            if currentIndex < pageCount - 1 {
                                currentIndex += 1
                            } else {
                                impactFeedback.impactOccurred()
                                withAnimation(.spring()) {
                                    bounceOffset = bounceAmount
                                    bounceOffset = 0
                                }
                            }
                        } else {  // Swipe down
                            if currentIndex > 0 {
                                currentIndex -= 1
                            } else {
                                impactFeedback.impactOccurred()
                                withAnimation(.spring()) {
                                    bounceOffset = -bounceAmount
                                    bounceOffset = 0
                                }
                            }
                        }
                    }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}
