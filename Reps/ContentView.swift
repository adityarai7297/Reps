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
                .foregroundColor(.white) // Change text color to white
                .scaleEffect(changeAmount != 0 ? 1.3 : 1.0)
                .animation(.easeOut(duration: 0.05), value: changeAmount)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "ff006e")) // Change background color to #ff006e
        .gesture(
            DragGesture()
                .onEnded { value in
                    let dragAmount = value.translation.height
                    changeAmount = -Int(dragAmount / 3) // Adjust the divisor to control sensitivity
                    changeAmount = max(min(changeAmount, 50), -50) // Limit changeAmount to [-50, 50]
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
                snapToNearestFive()
                timer?.invalidate()
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 5)) {
                    number = number
                }
            }
        }
    }

    func snapToNearestFive() {
        let remainder = number % 5
        if remainder != 0 {
            if remainder >= 3 {
                number += (5 - remainder)
            } else {
                number -= remainder
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
