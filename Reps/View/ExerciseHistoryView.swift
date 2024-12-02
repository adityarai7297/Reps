import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var exerciseName: String
    var onDelete: () -> Void
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    @State private var groupedExerciseHistory: [Date: [ExerciseHistory]] = [:]
    @State private var historyToEdit: ExerciseHistory? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(exerciseName)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)

            // History List
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(Array(groupedExerciseHistory.keys.sorted(by: >)), id: \.self) { date in
                        VStack(alignment: .leading, spacing: 16) {
                            // Date Header
                            Text(Formatter.date(date))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                            
                            // Exercise Records
                            ForEach(groupedExerciseHistory[date] ?? []) { history in
                                ExerciseHistoryCard(
                                    history: history,
                                    onDelete: { history in
                                        deleteHistory(history)
                                    },
                                    onEdit: { history in
                                        historyToEdit = history
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.black)
        .onAppear {
            loadExerciseHistory()
        }
        .sheet(item: $historyToEdit) { history in
            EditExerciseHistoryView(history: history)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .onDisappear {
                    loadExerciseHistory()
                }
        }
    }

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

    private func deleteHistory(_ history: ExerciseHistory) {
        modelContext.delete(history)
        do {
            try modelContext.save()
            onDelete()
            loadExerciseHistory()
            impactFeedback.impactOccurred()
        } catch {
            print("Failed to delete exercise history: \(error)")
        }
    }
}

// MARK: - Supporting Views

private struct ExerciseHistoryCard: View {
    let history: ExerciseHistory
    let onDelete: (ExerciseHistory) -> Void
    let onEdit: (ExerciseHistory) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Stats
            VStack(alignment: .leading, spacing: 8) {
                StatRow(label: "Weight", value: "\(Formatter.decimal(history.weight)) lbs")
                StatRow(label: "Reps", value: Formatter.decimal(history.reps))
                StatRow(label: "RPE", value: "\(Formatter.decimal(history.rpe))%")
                StatRow(label: "Time", value: Formatter.time(history.timestamp))
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: { onEdit(history) }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Button(action: { onDelete(history) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

