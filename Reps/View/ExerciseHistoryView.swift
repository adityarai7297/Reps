import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    var exerciseName: String
    var date: Date
    var onDelete: () -> Void // Callback to notify parent view of deletion

    @State private var exerciseHistory: [ExerciseHistory] = []

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(exerciseName)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                    .padding(.top, 32)

                Spacer()
                
                Text(formattedDay(date))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.trailing, 16)
                    .padding(.top, 32)
            }
            .padding(.bottom, 16)

            List {
                ForEach(exerciseHistory) { history in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight: \(history.weight, specifier: "%.1f") lbs")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Reps: \(history.reps, specifier: "%.0f")")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("RPE: \(history.rpe, specifier: "%.0f")%")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("Time: \(formattedTime(history.timestamp))")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        
                        // Delete button
                        Button(action: {
                            deleteHistory(history)
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Delete")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.darkGray))
                    .cornerRadius(10)
                }
                .listRowBackground(Color.black)  // Ensures each row has a dark background
            }
            .listStyle(PlainListStyle()) // Avoids any automatic background styling applied by default
            .background(Color.black) // Sets the entire list's background to black
            .onAppear {
                loadExerciseHistory()
            }
            .navigationTitle(exerciseName)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
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

    private func deleteHistory(_ history: ExerciseHistory) {
        modelContext.delete(history)
        do {
            try modelContext.save()
            // Notify parent view to recalculate set count
            onDelete()
            // Reload the history after deletion
            loadExerciseHistory()
        } catch {
            print("Failed to delete exercise history: \(error)")
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
