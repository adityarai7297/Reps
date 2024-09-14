import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    var exerciseName: String
    var onDelete: () -> Void // Callback to notify parent view of deletion
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

    @State private var groupedExerciseHistory: [Date: [ExerciseHistory]] = [:]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(exerciseName)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                    .padding(.top, 32)

                Spacer()
            }
            .padding(.bottom, 16)

            List {
                ForEach(Array(groupedExerciseHistory.keys.sorted(by: >)), id: \.self) { date in
                    Section(header: Text(formattedDate(date))
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.leading, 16)) {
                        ForEach(groupedExerciseHistory[date]!) { history in
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

                                Spacer()

                                // Delete button
                                Button(action: {
                                    impactFeedback.impactOccurred()
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
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                }
                .listRowBackground(Color.black)
                .animation(.default, value: groupedExerciseHistory)
            }
            .listStyle(PlainListStyle())
            .background(Color.black)
            .onAppear {
                loadExerciseHistory()
            }
            .navigationTitle(exerciseName)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func loadExerciseHistory() {
        // Fetch all ExerciseHistory objects for the given exercise, sorted by timestamp in descending order
        let fetchRequest = FetchDescriptor<ExerciseHistory>(
            predicate: #Predicate { history in
                history.exerciseName == exerciseName
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            let exerciseHistory = try modelContext.fetch(fetchRequest)
            groupedExerciseHistory = Dictionary(grouping: exerciseHistory) { history in
                Calendar.current.startOfDay(for: history.timestamp)
            }
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
