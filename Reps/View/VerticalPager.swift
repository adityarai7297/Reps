import SwiftUI

struct VerticalPager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let contentAtIndex: (Int) -> Content
    
    @State private var offset: CGFloat = 0
    @State private var animatedIndex: CGFloat = 0
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .soft)
    @State private var isDragging = false
    @State private var lastVelocity: CGFloat = 0
    @State private var isVerticalDrag: Bool = false
    
    // Ultra-smooth animation constants
    private let springResponse: Double = 0.45
    private let springDamping: Double = 0.85
    private let velocityThreshold: CGFloat = 150
    private let distanceThreshold: CGFloat = 20
    private let edgeResistance: CGFloat = 0.35
    private let scrollResistance: CGFloat = 0.98
    private let directionLockThreshold: CGFloat = 10
    
    // Vertical drag gesture
    private var verticalDragGesture: some Gesture {
        DragGesture(minimumDistance: directionLockThreshold, coordinateSpace: .local)
            .onChanged { value in
                // Only handle vertical drags
                let verticalDrag = abs(value.translation.height)
                let horizontalDrag = abs(value.translation.width)
                
                if !isDragging {
                    if verticalDrag > horizontalDrag {
                        isVerticalDrag = true
                    } else {
                        return
                    }
                }
                
                if isVerticalDrag {
                    isDragging = true
                    let translation = value.translation
                    let velocity = (translation.height - lastVelocity) / 2
                    lastVelocity = translation.height
                    
                    if (currentIndex == 0 && translation.height > 0) ||
                        (currentIndex == pageCount - 1 && translation.height < 0) {
                        let progress = abs(translation.height) / UIScreen.main.bounds.height
                        let resistance = max(edgeResistance * (1 - progress), 0.1)
                        offset = translation.height * resistance
                    } else {
                        offset = translation.height * scrollResistance
                    }
                }
            }
            .onEnded { value in
                guard isVerticalDrag else {
                    isDragging = false
                    isVerticalDrag = false
                    lastVelocity = 0
                    return
                }
                
                let predictedEndOffset = value.predictedEndLocation.y - value.location.y
                let velocity = (value.predictedEndLocation.y - value.location.y) / 0.1
                
                isDragging = false
                isVerticalDrag = false
                lastVelocity = 0
                
                var newIndex = currentIndex
                let translation = value.translation.height
                
                if translation < -distanceThreshold || velocity < -velocityThreshold {
                    if currentIndex < pageCount - 1 {
                        newIndex = currentIndex + 1
                        let intensity = min(abs(velocity) / 1500, 0.5)
                        impactFeedback.impactOccurred(intensity: intensity)
                    }
                } else if translation > distanceThreshold || velocity > velocityThreshold {
                    if currentIndex > 0 {
                        newIndex = currentIndex - 1
                        let intensity = min(abs(velocity) / 1500, 0.5)
                        impactFeedback.impactOccurred(intensity: intensity)
                    }
                }
                
                withAnimation(.spring(
                    response: springResponse,
                    dampingFraction: springDamping,
                    blendDuration: 0.15
                )) {
                    currentIndex = newIndex
                    animatedIndex = CGFloat(newIndex)
                    offset = 0
                }
            }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            
            ZStack {
                // Background gesture layer
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(verticalDragGesture)
                
                // Content layer
                ZStack {
                    ForEach((max(0, currentIndex - 1)...min(pageCount - 1, currentIndex + 1)), id: \.self) { index in
                        contentAtIndex(index)
                            .frame(width: geometry.size.width, height: height)
                            .offset(y: (CGFloat(index) - animatedIndex) * height + offset)
                            .zIndex(index == currentIndex ? 1 : 0)
                    }
                }
                .animation(
                    isDragging ? .interactiveSpring(response: 0.15, dampingFraction: 0.86) : .spring(
                        response: springResponse,
                        dampingFraction: springDamping,
                        blendDuration: 0.15
                    ),
                    value: offset
                )
                .animation(
                    .spring(
                        response: springResponse,
                        dampingFraction: springDamping,
                        blendDuration: 0.15
                    ),
                    value: animatedIndex
                )
                .simultaneousGesture(verticalDragGesture)
            }
            .onChange(of: currentIndex) { oldIndex, newIndex in
                withAnimation(.spring(
                    response: springResponse,
                    dampingFraction: springDamping,
                    blendDuration: 0.15
                )) {
                    animatedIndex = CGFloat(newIndex)
                }
            }
            .onAppear {
                animatedIndex = CGFloat(currentIndex)
                impactFeedback.prepare()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

