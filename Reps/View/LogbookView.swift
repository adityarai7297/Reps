import SwiftUI
import SwiftData

struct LogbookView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var groupedByDate: [Date: [String: [ExerciseHistory]]] = [:] // Group by date, then by exercise name
    @State private var groupedByExercise: [String: [Date: [ExerciseHistory]]] = [:] // Group by exercise, then by date
    @State private var selectedView: Int = 0 // 0 for date, 1 for exercise
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

            // Segment Control to switch between date view and exercise view
            Picker(selection: $selectedView, label: Text("View Selector")) {
                Text("By Date").tag(0)
                Text("By Exercise").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Conditionally show content based on selectedView
            if selectedView == 0 {
                // Existing view grouped by date
                FSCalendarView(selectedDate: $selectedDate, workoutData: workoutData)
                    .frame(height: 400)
                    .padding()

                if groupedByDate.isEmpty {
                    Text("No exercise history available")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding(.top, 20)
                        .padding(.leading, 16)
                } else if let date = selectedDate, let workoutsForDate = groupedByDate[Calendar.current.startOfDay(for: date)] {
                    exerciseList(for: workoutsForDate)
                } else {
                    Text("Select a date to view your workout history")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding(.top, 20)
                        .padding(.leading, 16)
                }
            } else {
                // New view grouped by exercise
                if groupedByExercise.isEmpty {
                    Text("No exercise history available")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding(.top, 20)
                        .padding(.leading, 16)
                } else {
                    List {
                        ForEach(groupedByExercise.keys.sorted(), id: \.self) { exerciseName in
                            Section(header: Text(exerciseName)
                                        .font(.headline)
                                        .padding(.leading, 16)
                                        .foregroundColor(.primary)) {

                                // Grouping by date within the exercise
                                ForEach(groupedByExercise[exerciseName]?.keys.sorted() ?? [], id: \.self) { date in
                                    Text("Date: \(formattedDate(date))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    ForEach(groupedByExercise[exerciseName]?[date] ?? [], id: \.self) { history in
                                        exerciseRow(history: history)
                                            .swipeActions(edge: .trailing) {
                                                deleteButton(for: history)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .padding(.horizontal, 16)
                }
            }
        }
        .onAppear {
            loadAllExerciseHistory()
        }
    }

    // Existing method to list workouts
    @ViewBuilder
    private func exerciseList(for workouts: [String: [ExerciseHistory]]) -> some View {
        List {
            ForEach(workouts.keys.sorted(), id: \.self) { exerciseName in
                Section(header: Text(exerciseName)
                            .font(.headline)
                            .padding(.leading, 16)
                            .foregroundColor(.primary)) {

                    ForEach(workouts[exerciseName] ?? [], id: \.self) { history in
                        exerciseRow(history: history)
                            .swipeActions(edge: .trailing) {
                                deleteButton(for: history)
                            }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .padding(.horizontal, 16)
    }

    // Extracted exercise row for reusability
    @ViewBuilder
    private func exerciseRow(history: ExerciseHistory) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Weight: ")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(history.weight == floor(history.weight) ? String(format: "%.0f", history.weight) : String(format: "%.1f", history.weight)) lbs")
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                HStack {
                    Text("Reps: ")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(history.reps == floor(history.reps) ? String(format: "%.0f", history.reps) : String(format: "%.1f", history.reps))")
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                HStack {
                    Text("RPE: ")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(history.rpe == floor(history.rpe) ? String(format: "%.0f", history.rpe) : String(format: "%.1f", history.rpe))%")
                        .font(.headline)
                        .foregroundColor(.primary)
                }

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
    }

    // Swipe to delete action
    @ViewBuilder
    private func deleteButton(for history: ExerciseHistory) -> some View {
        Button(role: .destructive) {
            impactFeedback.impactOccurred()
            withAnimation {
                itemsToDelete.insert(history)
                // Perform deletion after a delay for animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    deleteHistory(history)
                }
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // Modify this method to group by both date and exercise name
    private func loadAllExerciseHistory() {
        DispatchQueue.main.async {
            let fetchDescriptor = FetchDescriptor<ExerciseHistory>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )

            do {
                let allHistory = try modelContext.fetch(fetchDescriptor)

                // Grouping by date first, then by exercise name
                let groupedByDateTemp = Dictionary(grouping: allHistory) { history in
                    Calendar.current.startOfDay(for: history.timestamp)
                }.mapValues { histories in
                    Dictionary(grouping: histories) { $0.exerciseName }
                }

                // Grouping by exercise name first, then by date
                let groupedByExerciseTemp = Dictionary(grouping: allHistory) { history in
                    history.exerciseName
                }.mapValues { histories in
                    Dictionary(grouping: histories) { Calendar.current.startOfDay(for: $0.timestamp) }
                }

                groupedByDate = groupedByDateTemp
                groupedByExercise = groupedByExerciseTemp
                calculateSetCountForToday()
            } catch {
                print("Failed to load exercise history: \(error)")
            }
        }
    }

    private func deleteHistory(_ history: ExerciseHistory) {
        // Always perform deletion on the main thread for SwiftData
        DispatchQueue.main.async {
            modelContext.delete(history)
            do {
                try modelContext.save()

                // Remove the item from the deletion set and reload
                itemsToDelete.remove(history)
                loadAllExerciseHistory()
                calculateSetCountForToday()
                refreshTrigger.toggle() // Notify parent views about the change
            } catch {
                print("Failed to delete exercise history: \(error)")
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func calculateSetCountForToday() {
        // Always perform fetching on the main thread for SwiftData
        DispatchQueue.main.async {
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
                // Update the setCount on the main thread
                setCount = todayHistory.count
            } catch {
                // Ensure setCount is reset on the main thread in case of failure
                setCount = 0
                print("Failed to calculate set count: \(error)")
            }
        }
    }
}

// Custom Transition Modifier for Scale and Fade Animation
extension AnyTransition {
    static var scaleAndFade: AnyTransition {
        AnyTransition.scale(scale: 0.95)
            .combined(with: .opacity)
    }
}
