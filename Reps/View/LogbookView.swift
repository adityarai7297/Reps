import SwiftUI
import SwiftData

struct LogbookView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var groupedByDate: [Date: [String: [ExerciseHistory]]] = [:] // Group by date, then by exercise name
    @State private var selectedDate: Date? = nil // The date the user selects on the calendar
    @Binding var setCount: Int // Bind the set count from the parent view (ContentView)
    @Binding var refreshTrigger: Bool // Add this binding to notify changes
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Logbook")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
                .padding(.leading, 16)
                .padding(.top, 32)

            // FSCalendar implementation
            FSCalendarView(selectedDate: $selectedDate, workoutDays: Array(groupedByDate.keys))
                .frame(height: 400)
                .padding()

            if let date = selectedDate, let workoutsForDate = groupedByDate[Calendar.current.startOfDay(for: date)] {
                // Display the workout history for the selected date
                ScrollView {
                    ForEach(workoutsForDate.keys.sorted(), id: \.self) { exerciseName in
                        VStack(alignment: .leading) {
                            Text(exerciseName)
                                .font(.headline)
                                .padding(.leading, 16)
                                .foregroundColor(.primary)

                            ForEach(workoutsForDate[exerciseName] ?? [], id: \.self) { history in
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
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
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .padding()
            } else {
                Text("Select a date to view your workout history")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.leading, 16)
            }
        }
        .onAppear {
            loadAllExerciseHistory()
        }
    }

    // Loading all exercise history and grouping by date, then by exercise name
    private func loadAllExerciseHistory() {
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchDescriptor = FetchDescriptor<ExerciseHistory>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )

            do {
                // Fetch the data using the descriptor
                let allHistory = try modelContext.fetch(fetchDescriptor)

                // Group by date, then by exercise name
                let grouped = Dictionary(grouping: allHistory) { history in
                    Calendar.current.startOfDay(for: history.timestamp)
                }.mapValues { histories in
                    Dictionary(grouping: histories) { $0.exerciseName }
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
                    refreshTrigger.toggle() // Notify parent views about the change
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

            // Fetch today's exercise history with a descriptor and predicate
            let fetchDescriptor = FetchDescriptor<ExerciseHistory>(
                predicate: #Predicate { history in
                    history.timestamp >= startOfDay && history.timestamp < endOfDay
                }
            )

            do {
                let todayHistory = try modelContext.fetch(fetchDescriptor)

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
