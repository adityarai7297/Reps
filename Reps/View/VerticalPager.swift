import SwiftUI

struct VerticalPager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let contentAtIndex: (Int) -> Content
    
    @State private var bounceOffset: CGFloat = 0
    @State private var animatedIndex: CGFloat = 0
    
    // Optimized constants for instant response
    private let velocityThreshold: CGFloat = 100
    private let springResponse: Double = 0.15
    private let springDamping: Double = 0.85
    private let bounceAmount: CGFloat = 8
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        DispatchQueue.main.async {
            generator.impactOccurred(intensity: 0.4)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            
            ZStack {
                ForEach((max(0, currentIndex - 1)...min(pageCount - 1, currentIndex + 1)), id: \.self) { index in
                    contentAtIndex(index)
                        .frame(width: geometry.size.width, height: height)
                        .offset(y: (CGFloat(index) - animatedIndex) * height + bounceOffset)
                }
            }
            .onChange(of: currentIndex) { oldIndex, newIndex in
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
                                triggerHaptic()
                                currentIndex += 1
                            } else {
                                withAnimation(.spring(response: 0.15, dampingFraction: 0.8)) {
                                    bounceOffset = bounceAmount
                                }
                                withAnimation(.spring(response: 0.15, dampingFraction: 0.8).delay(0.05)) {
                                    bounceOffset = 0
                                }
                            }
                        } else {  // Swipe down
                            if currentIndex > 0 {
                                triggerHaptic()
                                currentIndex -= 1
                            } else {
                                withAnimation(.spring(response: 0.15, dampingFraction: 0.8)) {
                                    bounceOffset = -bounceAmount
                                }
                                withAnimation(.spring(response: 0.15, dampingFraction: 0.8).delay(0.05)) {
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
