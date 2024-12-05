import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.purple, lineWidth: 5)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 0.6)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.2)) {
                opacity = 1
            }
            isAnimating = true
        }
    }
}
