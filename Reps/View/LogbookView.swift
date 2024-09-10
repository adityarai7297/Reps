import SwiftUI
import SwiftData

struct LogbookView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var groupedByDate: [Date: [ExerciseHistory]] = [:] // State for grouping by date
    @Binding var setCount: Int // Bind the set count from the parent view (ContentView)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Exercise Logbook")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
                .padding(.leading, 16)
                .padding(.top, 32)

            if groupedByDate.isEmpty {
                Text("No exercise history available")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.leading, 16)
            } else {
                ScrollView {
                    ForEach(groupedByDate.keys.sorted(by: >), id: \.self) { date in
                        Section(header: Text(formattedDate(date))
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 16)) {
                            ForEach(groupedByDate[date] ?? [], id: \.self) { history in
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Exercise: \(history.exerciseName)")
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Text("Weight: \(history.weight, specifier: "%.1f") lbs")
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Text("Reps: \(history.reps, specifier: "%.0f")")
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Text("RPE: \(history.rpe, specifier: "%.0f")%")
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Text("Time: \(formattedTime(history.timestamp))")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()

                                    // Delete button for exercise history
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
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
        }
        .onAppear {
            loadAllExerciseHistory()
        }
    }

    // Loading all exercise history and grouping by date
    private func loadAllExerciseHistory() {
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchRequest = FetchDescriptor<ExerciseHistory>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )

            do {
                let allHistory = try modelContext.fetch(fetchRequest)

                // Group by date
                let grouped = Dictionary(grouping: allHistory) { history in
                    Calendar.current.startOfDay(for: history.timestamp)
                }

                DispatchQueue.main.async {
                    // Update the state on the main thread
                    groupedByDate = grouped

                    // Recalculate the set count for today
                    calculateSetCountForToday()
                }
            } catch {
                print("Failed to load exercise history: \(error)")
            }
        }
    }

    // Deleting history and reloading
    private func deleteHistory(_ history: ExerciseHistory) {
        DispatchQueue.global(qos: .userInitiated).async {
            modelContext.delete(history)
            do {
                try modelContext.save()

                DispatchQueue.main.async {
                    // Reload the history and recalculate set count on the main thread
                    loadAllExerciseHistory()
                    calculateSetCountForToday()
                }
            } catch {
                print("Failed to delete exercise history: \(error)")
            }
        }
    }

    // This function calculates today's set count
    private func calculateSetCountForToday() {
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            // Fetch today's exercise history
            let fetchRequest = FetchDescriptor<ExerciseHistory>(
                predicate: #Predicate { history in
                    history.timestamp >= startOfDay && history.timestamp < endOfDay
                }
            )

            do {
                let todayHistory = try modelContext.fetch(fetchRequest)

                DispatchQueue.main.async {
                    // Update the setCount on the main thread
                    setCount = todayHistory.count
                }
            } catch {
                DispatchQueue.main.async {
                    // Ensure setCount is reset on the main thread in case of failure
                    setCount = 0
                }
                print("Failed to calculate set count: \(error)")
            }
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
