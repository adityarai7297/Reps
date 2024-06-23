import SwiftUI

struct ContentView: View {
    @State private var number: Int = 0
    @State private var changeAmount: Int = 0
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Spacer()
            Text("\(number)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .scaleEffect(changeAmount != 0 ? 1.3 : 1.0)
                .animation(.easeOut(duration: 0.05), value: changeAmount)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let dragAmount = value.translation.height
                    changeAmount = -Int(dragAmount / 3) // Adjust the divisor to control sensitivity
                    startTimer()
                }
        )
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if changeAmount > 0 {
                number += 1
                changeAmount -= 1
            } else if changeAmount < 0 {
                number -= 1
                changeAmount += 1
            } else {
                timer?.invalidate()
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 5)) {
                    number = number
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
