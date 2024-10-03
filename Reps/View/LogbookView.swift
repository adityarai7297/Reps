import SwiftUI
import SwiftData

struct LogbookView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var groupedByDate: [Date: [String: [ExerciseHistory]]] = [:] // Group by date, then by exercise name
    @State private var selectedDate: Date? = nil // The date the user selects on the calendar
    @Binding var setCount: Int // Bind the set count from the parent view (ContentView)
    @Binding var refreshTrigger: Bool // Add this binding to notify changes
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    @State private var itemsToDelete: Set<ExerciseHistory> = [] // Track items being deleted

    // Computed property to construct workoutData
    var workoutData: [Date: Int] {
        groupedByDate.reduce(into: [:]) { result, entry in
            let (date, exercisesDict) = entry
            // Sum the counts of ExerciseHistory arrays to get total sets
            let totalSets = exercisesDict.values.reduce(0) { $0 + $1.count }
            // Only include dates with non-zero sets
            result[date] = totalSets
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Logbook")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
                .padding(.leading, 16)
                .padding(.top, 32)

            // FSCalendar implementation with workoutData
            FSCalendarView(selectedDate: $selectedDate, workoutData: workoutData)
                .frame(height: 400)
                .padding()

            if groupedByDate.isEmpty {
                // Show a default view if no history is available
                Text("No exercise history available")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.leading, 16)
            } else if let date = selectedDate, let workoutsForDate = groupedByDate[Calendar.current.startOfDay(for: date)] {
                // Replace ScrollView with List to support swipe actions
                List {
                    ForEach(workoutsForDate.keys.sorted(), id: \.self) { exerciseName in
                        Section(header: Text(exerciseName)
                                    .font(.headline)
                                    .padding(.leading, 16)
                                    .foregroundColor(.primary)) {

                            ForEach(workoutsForDate[exerciseName] ?? [], id: \.self) { history in
                                if !itemsToDelete.contains(history) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            // Display weight, removing ".0" if it's a whole number
                                            HStack {
                                                Text("Weight: ")
                                                    .font(.headline) // Less bold and smaller font for the label
                                                    .foregroundColor(.secondary)
                                                Text("\(history.weight == floor(history.weight) ? String(format: "%.0f", history.weight) : String(format: "%.1f", history.weight)) lbs")
                                                    .font(.headline) // Larger and bolder font for the actual value
                                                    .foregroundColor(.primary)
                                            }

                                            // Display reps, removing ".0" if it's a whole number
                                            HStack {
                                                Text("Reps: ")
                                                    .font(.headline) // Less bold and smaller font for the label
                                                    .foregroundColor(.secondary)
                                                Text("\(history.reps == floor(history.reps) ? String(format: "%.0f", history.reps) : String(format: "%.1f", history.reps))")
                                                    .font(.headline) // Larger and bolder font for the actual value
                                                    .foregroundColor(.primary)
                                            }

                                            // Display RPE, removing ".0" if it's a whole number
                                            HStack {
                                                Text("RPE: ")
                                                    .font(.headline) // Less bold and smaller font for the label
                                                    .foregroundColor(.secondary)
                                                Text("\(history.rpe == floor(history.rpe) ? String(format: "%.0f", history.rpe) : String(format: "%.1f", history.rpe))%")
                                                    .font(.headline) // Larger and bolder font for the actual value
                                                    .foregroundColor(.primary)
                                            }

                                            // Time display remains unchanged
                                            HStack {
                                                Text("Time: ")
                                                    .font(.headline) // Less bold and smaller font for the label
                                                    .foregroundColor(.secondary)
                                                Text("\(formattedTime(history.timestamp))")
                                                    .font(.headline) // Larger and bolder font for the actual value
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(10)
                                    .transition(.scaleAndFade) // Apply custom transition
                                    .animation(.easeInOut(duration: 0.5), value: itemsToDelete) // Animate deletion
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            impactFeedback.impactOccurred() // Haptic feedback
                                            withAnimation {
                                                itemsToDelete.insert(history) // Mark as deleting
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    deleteHistory(history) // Perform deletion after animation
                                                }
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Ensure it behaves similarly to ScrollView
                .padding(.horizontal, 16) // Maintain the same padding as the original ScrollView
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

                // Group by date (normalized), then by exercise name
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
                    // Remove the item from the deletion set and reload
                    itemsToDelete.remove(history)
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

// Custom Transition Modifier for Scale and Fade Animation
extension AnyTransition {
    static var scaleAndFade: AnyTransition {
        AnyTransition.scale(scale: 0.95)
            .combined(with: .opacity)
    }
}
