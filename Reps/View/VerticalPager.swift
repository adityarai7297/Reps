import SwiftUI

struct VerticalPager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let contentAtIndex: (Int) -> Content

    @GestureState private var dragOffset: CGFloat = 0

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
                    .onEnded { value in
                        let threshold = height / 2
                        if value.predictedEndTranslation.height < -threshold, currentIndex < pageCount - 1 {
                            currentIndex += 1
                        } else if value.predictedEndTranslation.height > threshold, currentIndex > 0 {
                            currentIndex -= 1
                        }
                    }
            )
            .animation(.interactiveSpring(), value: dragOffset)
            .animation(.interactiveSpring(), value: currentIndex)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
