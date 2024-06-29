import SwiftUI

struct ContentView: View {
    @State private var weightWheelConfig: WheelPicker.Config = .init(
        count: 100,
        steps: 10,
        spacing: 7,
        multiplier: 5
    )
    @State private var repWheelConfig: WheelPicker.Config = .init(
        count: 100,
        steps: 1,
        spacing: 50,
        multiplier: 1
    )
    
    @State private var exertionWheelConfig: WheelPicker.Config = .init(
        count: 10,
        steps: 1,
        spacing: 50,
        multiplier: 10
    )
    
    @State private var exerciseStates: [ExerciseState] = [
        ExerciseState(weightValue: 100, repValue: 4, exertionValue: 50, setCount: 0, showCheckmark: false),
        ExerciseState(weightValue: 100, repValue: 4, exertionValue: 50, setCount: 0, showCheckmark: false),
        ExerciseState(weightValue: 100, repValue: 4, exertionValue: 50, setCount: 0, showCheckmark: false),
        ExerciseState(weightValue: 100, repValue: 4, exertionValue: 50, setCount: 0, showCheckmark: false)
    ]
    
    @State private var currentIndex: Int = 0

    var body: some View {
        let colors: [Color] = [Color(hex: "d4e09b"),
                               Color(hex: "f6f4d2"),
                               Color(hex: "cbdfbd"),
                               Color(hex: "f19c79")]
        let exerciseNames = ["Bench Press", "Squat", "Deadlift", "Bicep Curl"]

        VerticalPager(pageCount: exerciseStates.count, currentIndex: $currentIndex) {
            ForEach(exerciseStates.indices, id: \.self) { index in
                ExerciseView(
                    exerciseName: exerciseNames[index],
                    state: $exerciseStates[index],
                    weightWheelConfig: weightWheelConfig,
                    repWheelConfig: repWheelConfig,
                    exertionWheelConfig: exertionWheelConfig,
                    color: colors[index]
                )
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00ff00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000ff) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    ContentView()
}
