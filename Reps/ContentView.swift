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
    
    // TODO: Initialization configs will be loaded from firebase eventually
    // load username
    // load exercise card data
    // last stored value variable
    @State private var weightValue: CGFloat = 100
    @State private var repValue: CGFloat = 4
    @State private var exertionValue: CGFloat = 50
    @State private var showCheckmark: Bool = false
    @State private var setCount: Int = 0
    @State private var currentIndex: Int = 0
    
    var exercises: [ExerciseView] {
        [
            ExerciseView(
                exerciseName: "Bench Press",
                weightValue: $weightValue,
                repValue: $repValue,
                exertionValue: $exertionValue,
                setCount: $setCount,
                showCheckmark: $showCheckmark,
                weightWheelConfig: weightWheelConfig,
                repWheelConfig: repWheelConfig,
                exertionWheelConfig: exertionWheelConfig
            ),
            ExerciseView(
                exerciseName: "Squat",
                weightValue: $weightValue,
                repValue: $repValue,
                exertionValue: $exertionValue,
                setCount: $setCount,
                showCheckmark: $showCheckmark,
                weightWheelConfig: weightWheelConfig,
                repWheelConfig: repWheelConfig,
                exertionWheelConfig: exertionWheelConfig
            ),
            ExerciseView(
                exerciseName: "Deadlift",
                weightValue: $weightValue,
                repValue: $repValue,
                exertionValue: $exertionValue,
                setCount: $setCount,
                showCheckmark: $showCheckmark,
                weightWheelConfig: weightWheelConfig,
                repWheelConfig: repWheelConfig,
                exertionWheelConfig: exertionWheelConfig
            ),
            ExerciseView(
                exerciseName: "Bicep Curl",
                weightValue: $weightValue,
                repValue: $repValue,
                exertionValue: $exertionValue,
                setCount: $setCount,
                showCheckmark: $showCheckmark,
                weightWheelConfig: weightWheelConfig,
                repWheelConfig: repWheelConfig,
                exertionWheelConfig: exertionWheelConfig
            )
        ]
    }
    
    var body: some View {
        VerticalPager(pageCount: exercises.count, currentIndex: $currentIndex) {
            ForEach(0..<exercises.count, id: \.self) { index in
                exercises[index]
            }
        }
    }
}

#Preview {
    ContentView()
}
