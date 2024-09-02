import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    var exerciseName: String
    var date: Date

    @State private var exerciseStates: [ExerciseState] = []

    var body: some View {
        List(exerciseStates) { state in
            VStack(alignment: .leading) {
                Text("Weight: \(state.lastWeightValue) lbs")
                Text("Reps: \(Int(state.lastRepValue))")
                Text("RPE: \(Int(state.lastRPEValue))")
                Text("Set Count: \(state.setCount)")
            }
            .padding()
        }
        .onAppear {
            loadExerciseStates()
        }
        .navigationTitle("\(exerciseName) on \(formattedDate(date))")
    }
    
    private func loadExerciseStates() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Fetch all ExerciseState objects with a non-nil timestamp within the date range
        let fetchRequest = FetchDescriptor<ExerciseState>(
            predicate: #Predicate { state in
                if let timestamp = state.timestamp {
                    return timestamp >= startOfDay && timestamp < endOfDay
                } else {
                    return false
                }
            }
        )
        
        do {
            let dateFilteredStates = try modelContext.fetch(fetchRequest)
            // Filter the results by exerciseName
            exerciseStates = dateFilteredStates.filter { state in
                state.exerciseName == exerciseName
            }
        } catch {
            print("Failed to load exercise states: \(error)")
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
