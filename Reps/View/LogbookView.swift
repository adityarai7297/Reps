import SwiftUI
import SwiftData

// MARK: - Logbook View
struct LogbookView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var groupedByDate: [Date: [String: [ExerciseHistory]]] = [:]
    @State private var exerciseHistories: [ExerciseHistory] = []
    @State private var selectedDate: Date? = nil
    @State private var expandedExercise: String? = nil
    @Binding var setCount: Int
    @Binding var refreshTrigger: Bool
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    @State private var itemsToDelete: Set<ExerciseHistory> = []
    @State private var historyToEdit: ExerciseHistory? = nil
    @State private var showingExerciseHistory = false
    @State private var showingGraphs = false

    var workoutData: [Date: Int] {
        groupedByDate.reduce(into: [:]) { result, entry in
            let (date, exercisesDict) = entry
            let totalSets = exercisesDict.values.reduce(0) { $0 + $1.count }
            result[date] = totalSets
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Dashboard")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                
                // Profile image placeholder
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)

            ScrollView {
                VStack(spacing: 24) {
                    // Activity Heatmap Section
                    VStack(alignment: .leading, spacing: 16) {
                        FSCalendarView(selectedDate: $selectedDate, workoutData: workoutData)
                            .frame(height: 360)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)

                    // Section Buttons
                    HStack(spacing: 16) {
                        // Exercise History Button
                        SectionButton(
                            title: "Exercise History",
                            icon: "dumbbell.fill",
                            action: {
                                impactFeedback.impactOccurred()
                                showingExerciseHistory = true
                            },
                            backgroundColor: .purple
                        )
                        
                        // Graphs Button
                        SectionButton(
                            title: "Graphs",
                            icon: "chart.line.uptrend.xyaxis",
                            action: {
                                impactFeedback.impactOccurred()
                                showingGraphs = true
                            },
                            backgroundColor: .blue
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Selected Date Workout History
                    if let date = selectedDate,
                       let workoutsForDate = groupedByDate[Calendar.current.startOfDay(for: date)] {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(Formatter.date(date))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            ForEach(Array(workoutsForDate.keys.sorted()), id: \.self) { exerciseName in
                                DailyWorkoutCard(
                                    exerciseName: exerciseName,
                                    histories: workoutsForDate[exerciseName] ?? [],
                                    onDelete: { history in
                                        deleteHistory(history)
                                    },
                                    onEdit: { history in
                                        historyToEdit = history
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .background(Color.black)
        .onAppear {
            loadAllExerciseHistory()
        }
        .sheet(isPresented: $showingExerciseHistory) {
            NavigationView {
                ExerciseHistoryModalView(exerciseHistories: exerciseHistories)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Exercise History")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
            }
        }
        .sheet(isPresented: $showingGraphs) {
            NavigationView {
                GraphsView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Graphs")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
            }
        }
        .sheet(item: $historyToEdit) { history in
            EditExerciseHistoryView(history: history)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Data Management Methods
    
    private func loadAllExerciseHistory() {
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

    private func deleteHistory(_ history: ExerciseHistory) {
        modelContext.delete(history)
        do {
            try modelContext.save()
            itemsToDelete.remove(history)
            loadAllExerciseHistory()
            calculateSetCountForToday()
            refreshTrigger.toggle()
            impactFeedback.impactOccurred()
        } catch {
            print("Failed to delete exercise history: \(error)")
        }
    }

    private func calculateSetCountForToday() {
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

// MARK: - Supporting Views

struct SectionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let backgroundColor: Color
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(backgroundColor.opacity(0.15))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

struct DailyWorkoutCard: View {
    let exerciseName: String
    let histories: [ExerciseHistory]
    let onDelete: (ExerciseHistory) -> Void
    let onEdit: (ExerciseHistory) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exerciseName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            ForEach(histories) { history in
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
        .padding(20)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

struct ExerciseHistoryModalView: View {
    let exerciseHistories: [ExerciseHistory]
    @Environment(\.dismiss) private var dismiss
    @State private var expandedExercise: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                let groupedByExercise = Dictionary(grouping: exerciseHistories, by: { $0.exerciseName })
                ForEach(groupedByExercise.keys.sorted(), id: \.self) { exerciseName in
                    ExerciseGroupCard(
                        exerciseName: exerciseName,
                        isExpanded: expandedExercise == exerciseName,
                        histories: groupedByExercise[exerciseName] ?? [],
                        onToggle: {
                            withAnimation {
                                if expandedExercise == exerciseName {
                                    expandedExercise = nil
                                } else {
                                    expandedExercise = exerciseName
                                }
                            }
                        },
                        onDelete: { _ in },
                        onEdit: { _ in }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.black)
    }
}

struct ExerciseGroupCard: View {
    let exerciseName: String
    let isExpanded: Bool
    let histories: [ExerciseHistory]
    let onToggle: () -> Void
    let onDelete: (ExerciseHistory) -> Void
    let onEdit: (ExerciseHistory) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(exerciseName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(20)
            }
            
            if isExpanded {
                let groupedHistories = Dictionary(grouping: histories) { history in
                    Calendar.current.startOfDay(for: history.timestamp)
                }
                
                ForEach(groupedHistories.keys.sorted(by: >), id: \.self) { date in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(Formatter.date(date))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        
                        ForEach(groupedHistories[date] ?? []) { history in
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    StatRow(label: "Weight", value: "\(Formatter.decimal(history.weight)) lbs")
                                    StatRow(label: "Reps", value: Formatter.decimal(history.reps))
                                    StatRow(label: "RPE", value: "\(Formatter.decimal(history.rpe))%")
                                    StatRow(label: "Time", value: Formatter.time(history.timestamp))
                                }
                                
                                Spacer()
                                
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
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}


