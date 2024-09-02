import SwiftUI
import SwiftData
import FirebaseFirestore

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var weightWheelConfig: WheelPicker.Config = .init(count: 100, steps: 10, spacing: 7, multiplier: 5)
    @State private var repWheelConfig: WheelPicker.Config = .init(count: 100, steps: 1, spacing: 50, multiplier: 1)
    @State private var exertionWheelConfig: WheelPicker.Config = .init(count: 10, steps: 1, spacing: 50, multiplier: 10)
    @State private var userId = "XXXXX"
    @State private var currentIndex: Int = 0
    @State private var exerciseStates: [ExerciseState] = []

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
                        loadExerciseData()
                    }
                }
            }
        }
        .onAppear {
            loadExerciseData()
        }
    }

    private func loadExerciseData() {
        let fetchRequest = FetchDescriptor<ExerciseState>() // Correct fetch descriptor for SwiftData

        do {
            let savedExerciseStates = try modelContext.fetch(fetchRequest)
            if !savedExerciseStates.isEmpty {
                exerciseStates = savedExerciseStates
            } else {
                // If there are no saved exercises, populate with default exercises
                loadDefaultExercises()
            }
        } catch {
            print("Failed to load exercise states: \(error)")
        }
    }

    private func loadDefaultExercises() {
        // Create default exercise states
        let defaultExercises = [
            ExerciseState(exerciseName: "Bench Press", lastWeightValue: 135.0, lastRepValue: 8, lastRPEValue: 7, setCount: 3, timestamp: Date()),
            ExerciseState(exerciseName: "Squat", lastWeightValue: 185.0, lastRepValue: 6, lastRPEValue: 8, setCount: 4, timestamp: Date()),
            ExerciseState(exerciseName: "Deadlift", lastWeightValue: 225.0, lastRepValue: 5, lastRPEValue: 9, setCount: 3, timestamp: Date())
        ]
        
        exerciseStates = defaultExercises

        // Save these default exercises to the model context
        for exercise in defaultExercises {
            modelContext.insert(exercise)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save default exercise states: \(error)")
        }
    }
}
