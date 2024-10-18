import SwiftUI
import SwiftData

struct LogbookView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var groupedByDate: [Date: [String: [ExerciseHistory]]] = [:] // Group by date, then by exercise name
    @State private var exerciseHistories: [ExerciseHistory] = [] // Holds all fetched ExerciseHistory objects
    @State private var selectedView: Int = 0 // 0 for date, 1 for exercise
    @State private var selectedDate: Date? = nil // The date the user selects on the calendar
    @State private var expandedExercise: String? = nil // Track which exercise name is expanded
    @Binding var setCount: Int // Bind the set count from the parent view (ContentView)
    @Binding var refreshTrigger: Bool // Add this binding to notify changes
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    @State private var itemsToDelete: Set<ExerciseHistory> = [] // Track items being deleted

    // Use Optional Binding for the edit modal
    @State private var historyToEdit: ExerciseHistory? = nil

    // Computed property to construct workoutData for calendar display (summarizes sets by date)
    var workoutData: [Date: Int] {
        groupedByDate.reduce(into: [:]) { result, entry in
            let (date, exercisesDict) = entry
            let totalSets = exercisesDict.values.reduce(0) { $0 + $1.count }
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

            // Segment Control to switch between views
            Picker(selection: $selectedView, label: Text("View Selector")) {
                Text("By Date").tag(0)
                Text("By Exercise").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Conditionally show content based on selectedView
            if selectedView == 0 {
                // Calendar View (Group by Date)
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
                    // Display grouped exercises for the selected date
                    exerciseList(for: workoutsForDate)
                } else {
                    Text("Select a date to view your workout history")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding(.top, 20)
                        .padding(.leading, 16)
                }
            } else {
                // Endless scroll grouped by Exercise (Group by Exercise)
                let groupedByExercise = Dictionary(grouping: exerciseHistories, by: { $0.exerciseName })

                if groupedByExercise.isEmpty {
                    Text("No exercise history available")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding(.top, 20)
                        .padding(.leading, 16)
                } else {
                    List {
                        // Reverse the keys for latest first sorting
                        ForEach(groupedByExercise.keys.sorted(by: >), id: \.self) { exerciseName in
                            Section(header: Button(action: {
                                // Toggle expanded state for the tapped exercise
                                withAnimation {
                                    if expandedExercise == exerciseName {
                                        expandedExercise = nil
                                    } else {
                                        expandedExercise = exerciseName
                                    }
                                }
                            }) {
                                HStack {
                                    Text(exerciseName)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.top, 10)
                                    Spacer()
                                    Image(systemName: expandedExercise == exerciseName ? "chevron.up" : "chevron.down")
                                }
                            }) {
                                // If this exercise is expanded, show its history
                                if expandedExercise == exerciseName {
                                    let historiesByDate = Dictionary(grouping: groupedByExercise[exerciseName] ?? [], by: { Calendar.current.startOfDay(for: $0.timestamp) })

                                    // Display the exercise history grouped by date
                                    ForEach(historiesByDate.keys.sorted(by: >), id: \.self) { date in
                                        Section(header: Text(formattedDate(date))) {
                                            ForEach(historiesByDate[date] ?? [], id: \.self) { history in
                                                exerciseRow(history: history)
                                                    .id(history.id)  // Add unique identifier to avoid reuse bugs
                                                    
                                            }
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
        // Present the edit modal when needed
        .sheet(item: $historyToEdit, onDismiss: {
            loadAllExerciseHistory()
        }) { history in
            EditExerciseHistoryView(history: history)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // Existing method to list workouts (grouped by date)
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
                            .id(history.id)  // Add unique identifier to avoid reuse bugs
                            .listRowBackground(Color.clear) // Disable highlighting
                            .contentShape(Rectangle())  // Define the tappable area explicitly
                            .allowsHitTesting(false)    // Disable interaction
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
                    Text(formattedTime(history.timestamp))
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        // Swipe actions for editing and deleting
        .swipeActions(edge: .leading) {
            editButton(for: history)
        }
        .swipeActions(edge: .trailing) {
            deleteButton(for: history)
        }
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

    // Swipe to edit action
    @ViewBuilder
    private func editButton(for history: ExerciseHistory) -> some View {
        Button {
            historyToEdit = history
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
    }

    // Load all exercise history (fetch logic remains unchanged)
    private func loadAllExerciseHistory() {
        DispatchQueue.main.async {
            let fetchDescriptor = FetchDescriptor<ExerciseHistory>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )

            do {
                let allHistory = try modelContext.fetch(fetchDescriptor)

                // Group by date for the calendar display
                groupedByDate = Dictionary(grouping: allHistory) { history in
                    Calendar.current.startOfDay(for: history.timestamp)
                }.mapValues { histories in
                    Dictionary(grouping: histories) { $0.exerciseName }
                }

                // Store all histories for "By Exercise" tab
                exerciseHistories = allHistory
                calculateSetCountForToday()
            } catch {
                print("Failed to load exercise history: \(error)")
            }
        }
    }

    // Perform deletion for a specific history
    private func deleteHistory(_ history: ExerciseHistory) {
        DispatchQueue.main.async {
            modelContext.delete(history)
            do {
                try modelContext.save()

                // Remove the item from the deletion set and reload data
                itemsToDelete.remove(history)
                loadAllExerciseHistory()
                calculateSetCountForToday()
                refreshTrigger.toggle() // Notify parent views about the change
            } catch {
                print("Failed to delete exercise history: \(error)")
            }
        }
    }

    // Date formatter for headers
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // Time formatter for each exercise entry
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Calculate the set count for today's workout
    private func calculateSetCountForToday() {
        DispatchQueue.main.async {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            let fetchDescriptor = FetchDescriptor<ExerciseHistory>(
                predicate: #Predicate { history in
                    history.timestamp >= startOfDay && history.timestamp < endOfDay
                }
            )

            do {
                let todayHistory = try modelContext.fetch(fetchDescriptor)
                setCount = todayHistory.count
            } catch {
                setCount = 0
                print("Failed to calculate set count: \(error)")
            }
        }
    }
}
