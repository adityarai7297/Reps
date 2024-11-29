import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    var exerciseName: String
    var onDelete: () -> Void // Callback to notify parent view of deletion
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

    @State private var groupedExerciseHistory: [Date: [ExerciseHistory]] = [:]
    
    // State for edit modal
    @State private var historyToEdit: ExerciseHistory? = nil

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
                                    // Display weight
                                    HStack {
                                        Text("Weight: ")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text("\(history.weight == floor(history.weight) ? String(format: "%.0f", history.weight) : String(format: "%.1f", history.weight)) lbs")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }

                                    // Display reps
                                    HStack {
                                        Text("Reps: ")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text("\(history.reps == floor(history.reps) ? String(format: "%.0f", history.reps) : String(format: "%.1f", history.reps))")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }

                                    // Display RPE
                                    HStack {
                                        Text("RPE: ")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text("\(history.rpe == floor(history.rpe) ? String(format: "%.0f", history.rpe) : String(format: "%.1f", history.rpe))%")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }

                                    // Time display
                                    HStack {
                                        Text("Time: ")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text("\(formattedTime(history.timestamp))")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            // Swipe actions for Edit and Delete
                            .swipeActions(edge: .leading) {
                                editButton(for: history) // Edit button
                            }
                            .swipeActions(edge: .trailing) {
                                deleteButton(for: history) // Delete button
                            }
                        }
                    }
                }
                .listRowBackground(Color(UIColor.systemBackground))
                .animation(.default, value: groupedExerciseHistory)
            }
            .listStyle(PlainListStyle())
            .background(Color(UIColor.systemBackground))
            .onAppear {
                loadExerciseHistory()
            }
            .navigationTitle(exerciseName)
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
        // Show the Edit modal
        .sheet(item: $historyToEdit) { history in
            EditExerciseHistoryView(history: history)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .onDisappear {
                    loadExerciseHistory()
                }
        }
    }

    // Load the exercise history for the current exercise
    private func loadExerciseHistory() {
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

    // Swipe to delete action
    private func deleteButton(for history: ExerciseHistory) -> some View {
        Button(role: .destructive) {
            deleteHistory(history)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // Swipe to edit action
    private func editButton(for history: ExerciseHistory) -> some View {
        Button {
            historyToEdit = history // Open the edit modal
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
    }

    // Delete the history entry and reload
    private func deleteHistory(_ history: ExerciseHistory) {
        modelContext.delete(history)
        do {
            try modelContext.save()
            onDelete() // Trigger callback for deletion
            loadExerciseHistory() // Reload history after deletion
            impactFeedback.impactOccurred() // Haptic feedback
        } catch {
            print("Failed to delete exercise history: \(error)")
        }
    }

    // Date formatter for headers
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // Time formatter for entries
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

