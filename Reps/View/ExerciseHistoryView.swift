import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    var exerciseName: String
    var date: Date

    @State private var exerciseHistory: [ExerciseHistory] = []

    var body: some View {
        VStack {
            Text(formattedDay(date)) // Display the day on top
                .font(.headline)
                .padding(.top, 8)

            Text(exerciseName)
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.bottom, 8)

            List(exerciseHistory) { history in
                VStack(alignment: .leading) {
                    Text("Weight: \(history.weight, specifier: "%.1f") lbs")
                    Text("Reps: \(Int(history.reps))")
                    Text("RPE: \(Int(history.rpe))")
                    Text("Time: \(formattedTime(history.timestamp))")
                }
                .padding()
            }
            .onAppear {
                loadExerciseHistory()
            }
            .navigationTitle(exerciseName)
        }
    }
    
    private func loadExerciseHistory() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Fetch all ExerciseHistory objects for the given exercise and date range, sorted by timestamp in descending order
        let fetchRequest = FetchDescriptor<ExerciseHistory>(
            predicate: #Predicate { history in
                history.exercise.name == exerciseName &&
                history.timestamp >= startOfDay &&
                history.timestamp < endOfDay
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)] // Sort by timestamp in descending order
        )
        
        do {
            exerciseHistory = try modelContext.fetch(fetchRequest)
        } catch {
            print("Failed to load exercise history: \(error)")
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}
