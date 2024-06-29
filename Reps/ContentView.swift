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
        VerticalPager(pageCount: exerciseStates.count, currentIndex: $currentIndex) {
            ForEach(exerciseStates.indices, id: \.self) { index in
                ExerciseView(
                    exerciseName: ["Bench Press", "Squat", "Deadlift", "Bicep Curl"][index],
                    state: $exerciseStates[index],
                    weightWheelConfig: weightWheelConfig,
                    repWheelConfig: repWheelConfig,
                    exertionWheelConfig: exertionWheelConfig
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
