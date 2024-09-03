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
    @State private var exercises: [Exercise] = []

    var body: some View {
        ZStack {
            VerticalPager(pageCount: exercises.count, currentIndex: $currentIndex) {
                ForEach(exercises.indices, id: \.self) { index in
                    ExerciseView(
                        exercise: $exercises[index],
                        weightWheelConfig: weightWheelConfig,
                        repWheelConfig: repWheelConfig,
                        RPEWheelConfig: exertionWheelConfig,
                        color: .clear, // Set to clear since gradient will be applied
                        userId: userId
                    )
                    .gradientBackground(index: index)
                    .onAppear {
                        loadExercises()
                    }
                }
            }
        }
        .onAppear {
            loadExercises()
        }
    }

    private func loadExercises() {
        let fetchRequest = FetchDescriptor<Exercise>() // Correct fetch descriptor for SwiftData

        do {
            let savedExercises = try modelContext.fetch(fetchRequest)
            if !savedExercises.isEmpty {
                exercises = savedExercises
            } else {
                // If there are no saved exercises, populate with default exercises
                loadDefaultExercises()
            }
        } catch {
            print("Failed to load exercises: \(error)")
        }
    }

    private func loadDefaultExercises() {
        let defaultExercises = [
            Exercise(name: "Bench Press"),
            Exercise(name: "Squat"),
            Exercise(name: "Deadlift")
        ]
        
        exercises = defaultExercises

        // Save these default exercises to the model context
        for exercise in defaultExercises {
            modelContext.insert(exercise)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save default exercises: \(error)")
        }
    }
}
