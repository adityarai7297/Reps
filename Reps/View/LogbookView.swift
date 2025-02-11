import SwiftUI
import SwiftData

// MARK: - Logbook View
struct LogbookView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var groupedByDate: [Date: [String: [ExerciseHistory]]] = [:]
    @State private var selectedDate: Date? = nil
    @Binding var setCount: Int
    @Binding var refreshTrigger: Bool
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    @State private var historyToEdit: ExerciseHistory? = nil
    @AppStorage("hasShownActivityHint") private var hasShownActivityHint = false
    @State private var showActivityHint = false
    @State private var activityHintStep = 1
    @AppStorage("hasShownSwipeHint") private var hasShownSwipeHint = false
    @State private var showSwipeHint = false
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var inputText = ""
    @State private var workoutData: [Date: Int] = [:]
    @State private var showTopics = true
    @State private var showWorkoutPlanModal = false

    var body: some View {
        VStack(spacing: 0) {
            // Chat Messages
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(chatViewModel.messages) { message in
                        ChatBubble(
                            message: message,
                            selectedDate: $selectedDate,
                            workoutData: workoutData,
                            onQuestionSelected: { question in
                                handleUserInput(question)
                            }
                        )
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            // Selected Date History
            if let selectedDate = selectedDate {
                VStack(alignment: .leading, spacing: 8) {
                    Text(Formatter.date(selectedDate))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }
            }
            
            
            
            // Chat Input
            ChatInputField(
                text: $inputText,
                onSubmit: { handleUserInput(inputText) },
                chatViewModel: chatViewModel,
                onQuestionSelected: { question in
                    handleUserInput(question)
                }
            )
        }
        .background(Color.black)
        .onAppear {
            loadAllExerciseHistory()
            
            // Add initial greeting with suggested questions
            if chatViewModel.messages.isEmpty {
                chatViewModel.addMessage(
                    "Hi! I'm here to help you track your fitness journey. Ask me about your consistency or anything else!",
                    isUser: false,
                    suggestedQuestions: [
                        "Show me my workout history",
                        "What should I focus on today?",
                        "How can you help me?"
                    ]
                )
            }
        }
        .sheet(item: $historyToEdit) { history in
            EditExerciseHistoryView(history: history)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showWorkoutPlanModal) {
            WorkoutPlanOnboardingView()
        }
    }

    private func handleUserInput(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Always display the user's input as a chat bubble
        chatViewModel.addMessage(trimmed, isUser: true)
        inputText = ""
        showTopics = false

        let lowercasedText = trimmed.lowercased()

        // Process commands in a standardized way
        if lowercasedText.contains("make me a workout plan") {
            showWorkoutPlanModal = true
            chatViewModel.addMessage("Let's create your custom workout plan!", isUser: false)
            return
        } else if lowercasedText.contains("consistency") {
            chatViewModel.addMessage(
                "Here's a view of your workout consistency:",
                isUser: false,
                suggestedQuestions: [
                    "What's my best workout day?",
                    "How can I improve my consistency?",
                    "Show me my progress"
                ]
            )
            chatViewModel.addMessage(
                "Each square represents a day, and darker colors indicate more sets completed.",
                isUser: false,
                containsCalendar: true,
                suggestedQuestions: [
                    "What's my average sets per workout?",
                    "Which exercise do I do most often?",
                    "Set a consistency goal for me"
                ]
            )
            return
        } else {
            chatViewModel.addMessage(
                "I'm here to help! You can ask me about your consistency, and I'll show you a calendar view of your workouts.",
                isUser: false,
                suggestedQuestions: [
                    "Show me my consistency",
                    "What exercises should I do?",
                    "Help me set a workout goal"
                ]
            )
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

            calculateSetCountForToday()
        } catch {
            print("Failed to load exercise history: \(error)")
        }
    }

    private func deleteHistory(_ history: ExerciseHistory) {
        modelContext.delete(history)
        do {
            try modelContext.save()
            loadAllExerciseHistory()
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

// MARK: - Supporting Views

// MARK: - Section Button
struct SectionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let colors: [Color]
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(height: 22)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(height: 18)
            }
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DailyWorkoutCard: View {
    let exerciseName: String
    let histories: [ExerciseHistory]
    let onDelete: (ExerciseHistory) -> Void
    let onEdit: (ExerciseHistory) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(exerciseName)
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(histories) { history in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Formatter.decimal(history.weight)) lbs × \(Formatter.decimal(history.reps))")
                            .foregroundColor(.white)
                        Text("RPE: \(Formatter.decimal(history.rpe))%")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            onEdit(history)
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            onDelete(history)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(16)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(8)
    }
}

struct ExerciseHistoryModalView: View {
    let exerciseHistories: [ExerciseHistory]
    let onDelete: (ExerciseHistory) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var expandedExercise: String? = nil
    @State private var historyToEdit: ExerciseHistory? = nil
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 8)
                .padding(.bottom, 4)
            
            Text("Exercise History")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 20) {
                    let groupedByExercise = Dictionary(grouping: exerciseHistories, by: { $0.exerciseName })
                    ForEach(groupedByExercise.keys.sorted(), id: \.self) { exerciseName in
                        VStack {
                            Button(action: {
                                withAnimation {
                                    hapticFeedback.impactOccurred()
                                    if expandedExercise == exerciseName {
                                        expandedExercise = nil
                                    } else {
                                        expandedExercise = exerciseName
                                    }
                                }
                            }) {
                                HStack {
                                    Text(exerciseName)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: expandedExercise == exerciseName ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                            }
                            
                            if expandedExercise == exerciseName {
                                ForEach(groupedByExercise[exerciseName] ?? []) { history in
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            StatRow(label: "Weight", value: "\(Formatter.decimal(history.weight)) lbs")
                                            StatRow(label: "Reps", value: Formatter.decimal(history.reps))
                                            StatRow(label: "RPE", value: "\(Formatter.decimal(history.rpe))%")
                                            StatRow(label: "Time", value: Formatter.time(history.timestamp))
                                        }
                                        
                                        Spacer()
                                        
                                        // Action buttons
                                        HStack(spacing: 12) {
                                            Button(action: {
                                                hapticFeedback.impactOccurred()
                                                historyToEdit = history
                                            }) {
                                                Image(systemName: "pencil")
                                                    .foregroundColor(.blue)
                                                    .padding(8)
                                                    .background(Color.blue.opacity(0.2))
                                                    .cornerRadius(8)
                                            }
                                            
                                            Button(action: {
                                                hapticFeedback.impactOccurred()
                                                onDelete(history)
                                                if expandedExercise == exerciseName && groupedByExercise[exerciseName]?.count == 1 {
                                                    expandedExercise = nil
                                                }
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                                    .padding(8)
                                                    .background(Color.red.opacity(0.2))
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding(16)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(Color.black)
        .navigationBarHidden(true) // Hide the navigation bar
        .sheet(item: $historyToEdit) { history in
            EditExerciseHistoryView(history: history)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
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

// MARK: - GitHub Style Calendar View
struct GitHubStyleCalendarView: View {
    @Binding var selectedDate: Date?
    let workoutData: [Date: Int]
    private let calendar = Calendar.current
    private let weekdays = ["Sat", "Fri", "Thu", "Wed", "Tue", "Mon", "Sun"]
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
                
                // Calendar grid with months
                let dates = getAllDates()
                let monthPositions = calculateMonthPositions(for: dates)
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            // Month labels
                            ZStack(alignment: .topLeading) {
                                ForEach(monthPositions, id: \.date) { month in
                                    Text(month.name)
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                        .offset(x: month.offset)
                                }
                            }
                            .frame(height: 24)
                            .padding(.leading, 8)
                            
                            // Days grid
                            LazyHGrid(rows: Array(repeating: GridItem(.fixed(squareSize), spacing: squareSpacing), count: 7), spacing: squareSpacing) {
                                let weeks = dates.chunked(into: 7)
                                ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                                    ForEach(week.reversed(), id: \.self) { date in
                                        let count = workoutData[calendar.startOfDay(for: date)] ?? 0
                                        Rectangle()
                                            .fill(colorForCount(count))
                                            .frame(width: squareSize, height: squareSize)
                                            .cornerRadius(3)
                                            .onTapGesture {
                                                hapticFeedback.impactOccurred()
                                                selectedDate = date
                                            }
                                            .id(date)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    .flipsForRightToLeftLayoutDirection(true)
                    .onAppear {
                        // Scroll to the most recent date (last in the array)
                        withAnimation {
                            proxy.scrollTo(dates.last, anchor: .trailing)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            
            // Legend
            HStack(spacing: 6) {
                Text("Less")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                ForEach(0..<5) { level in
                    Rectangle()
                        .fill(colorForCount(level))
                        .frame(width: squareSize, height: squareSize)
                        .cornerRadius(3)
                }
                Text("More")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
    }
    
    private func getAllDates() -> [Date] {
        // Find the earliest workout date
        let earliestDate = workoutData.keys.min() ?? Date()
        let endDate = Date()
        
        // Get the start of the week containing the earliest date
        let weekday = calendar.component(.weekday, from: earliestDate)
        let daysToSubtract = weekday - 1 // weekday is 1-based, with 1 being Sunday
        var currentDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: calendar.startOfDay(for: earliestDate))!
        
        var dates: [Date] = []
        
        // Add dates until we reach the end date
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Add any remaining days to complete the last week
        let lastWeekday = calendar.component(.weekday, from: currentDate)
        if lastWeekday > 1 {
            let daysToAdd = 8 - lastWeekday
            for _ in 0..<daysToAdd {
                dates.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        }
        
        // Group into weeks and reverse each week's order
        let weeks = dates.chunked(into: 7).map { $0.reversed() }
        return weeks.flatMap { $0 }.reversed() // Newest to oldest
    }
    
    private struct MonthPosition {
        let name: String
        let date: Date
        let offset: CGFloat
    }
    
    private func calculateMonthPositions(for dates: [Date]) -> [MonthPosition] {
        var positions: [MonthPosition] = []
        var currentDate = dates.first!
        
        while currentDate >= dates.last! {
            let startOfMonth = calendar.startOfMonth(for: currentDate)
            
            if calendar.isDate(currentDate, equalTo: startOfMonth, toGranularity: .day) {
                let daysFromStart = calendar.dateComponents([.day], from: dates.first!, to: currentDate).day!
                let columnIndex = abs(daysFromStart) / 7
                let offset = CGFloat(columnIndex) * columnWidth
                
                let monthName = calendar.shortMonthSymbols[calendar.component(.month, from: currentDate) - 1]
                positions.append(MonthPosition(name: monthName, date: currentDate, offset: offset))
            }
            
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return positions
    }
    
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0:
            return Color.gray.opacity(0.2)
        case 1:
            return Color.green.opacity(0.3)
        case 2...3:
            return Color.green.opacity(0.5)
        case 4...6:
            return Color.green.opacity(0.7)
        default:
            return Color.green.opacity(0.9)
        }
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

