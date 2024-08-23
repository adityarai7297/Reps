import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @State private var weightWheelConfig: WheelPicker.Config = .init(count: 100, steps: 10, spacing: 7, multiplier: 5)
    @State private var repWheelConfig: WheelPicker.Config = .init(count: 100, steps: 1, spacing: 50, multiplier: 1)
    @State private var exertionWheelConfig: WheelPicker.Config = .init(count: 10, steps: 1, spacing: 50, multiplier: 10)
    @State private var exerciseStates: [ExerciseState] = [
        ExerciseState(exerciseName: "Bench Press", lastWeightValue: 135.0, lastRepValue: 8, lastRPEValue: 7, setCount: 3, showCheckmark: false),
        ExerciseState(exerciseName: "Squat", lastWeightValue: 185.0, lastRepValue: 6, lastRPEValue: 8, setCount: 4, showCheckmark: false),
        ExerciseState(exerciseName: "Deadlift", lastWeightValue: 225.0, lastRepValue: 5, lastRPEValue: 9, setCount: 3, showCheckmark: false),
        ExerciseState(exerciseName: "Overhead Press", lastWeightValue: 95.0, lastRepValue: 10, lastRPEValue: 6, setCount: 3, showCheckmark: false),
        ExerciseState(exerciseName: "Barbell Row", lastWeightValue: 115.0, lastRepValue: 8, lastRPEValue: 7, setCount: 4, showCheckmark: false)
    ]
    @State private var userId = "XXXXX"
    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack {
                VerticalPager(pageCount: exerciseStates.count, currentIndex: $currentIndex) {
                    ForEach(exerciseStates.indices, id: \.self) { index in
                        ExerciseView(
                            state: $exerciseStates[index],
                            exerciseName: $exerciseStates[index].exerciseName,
                            weightWheelConfig: weightWheelConfig,
                            repWheelConfig: repWheelConfig,
                            RPEWheelConfig: exertionWheelConfig,
                            color: .clear, // Set to clear since gradient will be applied
                            userId: userId
                        )
                        .gradientBackground(index: index)
                        .onAppear {
                            
                        }
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

