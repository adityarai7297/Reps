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
                
                VStack { // Stack day and date vertically
                                    Text(formattedDay(date))
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Text(formattedDate(date))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 16)
                                .padding(.top, 32)
            }
            .padding(.bottom, 16)

            List {
                ForEach(exerciseHistory) { history in
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weight: \(history.weight, specifier: "%.1f") lbs")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Reps: \(history.reps, specifier: "%.0f")")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                           
                                Text("RPE: \(history.rpe, specifier: "%.0f")%")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                
                                Text("Time: \(formattedTime(history.timestamp))")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            
                        }

                        Spacer() // Push the delete button to the right

                        // Delete button on the right side
                        Button(action: {
                            withAnimation {
                                deleteHistory(history)
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding()
                    .background(Color(.darkGray))
                    .cornerRadius(10)
                }
                .listRowBackground(Color.black)  // Ensures each row has a dark background
                .animation(.default, value: exerciseHistory) // Animation for row changes
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
                history.timestamp >= startOfDay && history.timestamp < endOfDay
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)] // Sort by timestamp in descending order
        )
        
        do {
            exerciseHistory = try modelContext.fetch(fetchRequest)
            exerciseHistory = exerciseHistory.filter { $0.exercise.name == exerciseName }
        } catch {
            print("Failed to load exercise history: \(error)")
        }
    }

    private func deleteHistory(_ history: ExerciseHistory) {
        modelContext.delete(history)
        do {
            try modelContext.save()
            onDelete() // Trigger the set count recalculation
            loadExerciseHistory() // Reload the history after deletion
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
            formatter.dateFormat = "EEEE" // Display the day name, e.g., "Monday"
            return formatter.string(from: date)
        }
        
        private func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium // Display the date, e.g., "Sep 3, 2023"
            return formatter.string(from: date)
        }
}
