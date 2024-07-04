import SwiftUI

struct VerticalPager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let content: () -> Content
    
    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: @escaping () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content
    }
    
    @GestureState private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            LazyVStack(spacing: 0) {
                self.content()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primary.opacity(0.000000001))
            .offset(y: -CGFloat(self.currentIndex) * geometry.size.height)
            .offset(y: self.translation)
            .animation(.interactiveSpring(response: 0.3), value: currentIndex)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .updating(self.$translation) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let offset = -Int(value.translation.height)
                        if abs(offset) > Int(geometry.size.height / 2) || abs(value.velocity.height) > 200 {
                            let newIndex = currentIndex + (value.translation.height > 0 ? -1 : 1)
                            if newIndex >= 0 && newIndex < pageCount {
                                self.currentIndex = newIndex
                            }
                        }
                    }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct VerticalPager_Previews: PreviewProvider {
    static var previews: some View {
        VerticalPager(pageCount: 5, currentIndex: .constant(0)) {
            ForEach(0..<5) { index in
                Text("Page \(index)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.red)
            }
        }
    }
}
