struct LogbookView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var groupedByDate: [Date: [String: [ExerciseHistory]]] = [:]
    @State private var exerciseHistories: [ExerciseHistory] = []
    @State private var selectedDate: Date? = nil
    @State private var expandedExercise: String? = nil
    @Binding var setCount: Int
    @Binding var refreshTrigger: Bool
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    @State private var showingExerciseHistory = false
    @State private var showingGraphs = false
    @State private var historyToEdit: ExerciseHistory? = nil
    @AppStorage("hasShownActivityHint") private var hasShownActivityHint = false
    @State private var showActivityHint = false
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var workoutData: [Date: Int] {
        groupedByDate.reduce(into: [:]) { result, entry in
            let (date, exercisesDict) = entry
            let totalSets = exercisesDict.values.reduce(0) { $0 + $1.count }
            result[date] = totalSets
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {            
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
                            // Activity Overview with GitHub-style calendar
                            VStack(alignment: .leading, spacing: 16) {
                                GitHubStyleCalendarView(selectedDate: $selectedDate, workoutData: workoutData)
                                    .frame(height: 180)
                                    .padding(.vertical, 20)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                            .blur(radius: showActivityHint ? 10 : 0)
                            .animation(.easeInOut(duration: 0.3), value: showActivityHint)

                            // Section Buttons
                            HStack(spacing: 16) {
                                // Exercise History Button
                                SectionButton(
                                    title: "Exercise History",
                                    icon: "dumbbell.fill",
                                    action: {
                                        hapticFeedback.impactOccurred()
                                        showingExerciseHistory = true
                                    },
                                    backgroundColor: .purple
                                )
                                
                                // Graphs Button
                                SectionButton(
                                    title: "Graphs",
                                    icon: "chart.line.uptrend.xyaxis",
                                    action: {
                                        hapticFeedback.impactOccurred()
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
                
                // Hint overlay
                if showActivityHint {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                        Text("Your activity trace will appear here\nas you log your workouts")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(20)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(15)
                    .transition(.opacity)
                }
            }
            .background(Color.black)
            .onAppear {
                loadAllExerciseHistory()
                // Show activity hint if it hasn't been shown before
                if !hasShownActivityHint {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn(duration: 0.5)) {
                            showActivityHint = true
                            // Dismiss the hint after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    showActivityHint = false
                                    hasShownActivityHint = true
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingExerciseHistory) {
                NavigationView {
                    ExerciseHistoryModalView(
                        exerciseHistories: exerciseHistories,
                        onDelete: { history in
                            deleteHistory(history)
                        }
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Exercise History")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                .background(Color.black)
                .preferredColorScheme(.dark)
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
                .background(Color.black)
                .preferredColorScheme(.dark)
            }
            .sheet(item: $historyToEdit) { history in
                EditExerciseHistoryView(history: history)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
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
            loadAllExerciseHistory() // Reload all data
            calculateSetCountForToday()
            refreshTrigger.toggle()
            hapticFeedback.impactOccurred()
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

// MARK: - GitHub Style Calendar View
struct GitHubStyleCalendarView: View {
    @Binding var selectedDate: Date?
    let workoutData: [Date: Int]
    private let calendar = Calendar.current
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let squareSize: CGFloat = 16
    private let squareSpacing: CGFloat = 4
    private let columnWidth: CGFloat = 20
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 4) {
                // Weekday labels column
                VStack(alignment: .leading, spacing: 4) {
                    Text("")
                        .frame(height: 24)
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .frame(height: 16)
                    }
                }
                .frame(width: 40)
                .padding(.trailing, 8)
                // ... existing code ...
            }
        }
    }
} 