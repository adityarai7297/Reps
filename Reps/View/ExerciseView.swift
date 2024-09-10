import SwiftUI
import SwiftData

struct ExerciseView: View {
    @Binding var exercise: Exercise
    @State private var showCheckmark: Bool = false
    @State private var showingHistory = false
    @Environment(\.modelContext) private var modelContext
    @State private var currentWeight: CGFloat = 0
    @State private var currentReps: CGFloat = 0
    @State private var currentRPE: CGFloat = 0
    @State private var setCount: Int = 0 // This tracks the number of sets for today
    let weightWheelConfig: WheelPicker.Config
    let repWheelConfig: WheelPicker.Config
    let RPEWheelConfig: WheelPicker.Config
    let color: Color
    let userId: String
    
    var body: some View {
        VStack {
            VStack {
                Spacer().frame(height: 40)
                Text(exercise.name)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                Spacer().frame(height: 40)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: UIScreen.main.bounds.width, height: 0.2)

                Spacer().frame(height: 60)

                VStack {
                    HStack(alignment: .lastTextBaseline, spacing: 5) {
                        Text("\(currentWeight, specifier: "%.1f")")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: currentWeight))
                            .animation(.easeInOut(duration: 0.2), value: currentWeight)

                        Text("lbs")
                            .font(.title2)
                            .fontWeight(.light)
                            .textScale(.secondary)
                    }

                    WheelPicker(config: weightWheelConfig, value: $currentWeight)
                        .frame(height: 60)
                }

                Spacer().frame(height: 40)

                VStack {
                    HStack(alignment: .lastTextBaseline, spacing: 5) {
                        Text("\(currentReps, specifier: "%.0f")") // Keeping currentReps as CGFloat
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: currentReps))
                            .animation(.easeInOut(duration: 0.2), value: currentReps)

                        Text("reps")
                            .font(.title2)
                            .fontWeight(.light)
                            .textScale(.secondary)
                    }

                    WheelPicker(config: repWheelConfig, value: $currentReps)
                        .frame(height: 60)
                }

                Spacer().frame(height: 40)

                VStack {
                    HStack(alignment: .lastTextBaseline, spacing: 5) {
                        Text("\(currentRPE, specifier: "%.0f")") // Keeping currentRPE as CGFloat
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: currentRPE))
                            .animation(.easeInOut(duration: 0.2), value: currentRPE)

                        Text("% RPE")
                            .font(.title2)
                            .fontWeight(.light)
                            .textScale(.secondary)
                    }

                    WheelPicker(config: RPEWheelConfig, value: $currentRPE)
                        .frame(height: 60)
                }
            }
            .offset(y: showCheckmark ? -60 : 0)
            .onAppear {
                loadCurrentValues()  // Load the most recent values for this exercise
                calculateSetCountForToday() // Calculate the set count based on today's history
            }

            Spacer().frame(height: 60)

            HStack {
                Spacer().frame(width: 100)
                SetButton(showCheckmark: $showCheckmark, setCount: $setCount, action: {
                    saveExerciseHistory()
                })
                Spacer().frame(width: 30)
                HStack {
                    Text("\(setCount)")
                        .font(.title)

                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .opacity(setCount > 0 ? 1 : 0)
                .onTapGesture {
                    showingHistory.toggle()
                }
                .sheet(isPresented: $showingHistory) {
                    ExerciseHistoryView(exerciseName: exercise.name, onDelete: {
                        calculateSetCountForToday()
                    })
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.black)
        .background(color)
        .edgesIgnoringSafeArea(.all)
    }
    
    // Optimized loadCurrentValues with DispatchQueue
    private func loadCurrentValues() {
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            // Step 1: Fetch all ExerciseHistory records for this exercise
            let fetchRequest = FetchDescriptor<ExerciseHistory>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )

            do {
                // Fetch all the exercise history records on background thread
                let allHistory = try modelContext.fetch(fetchRequest)

                // Step 2: Filter for the current exercise and today's date
                let todayHistory = allHistory.filter { history in
                    history.exerciseName == exercise.name && history.timestamp >= startOfDay && history.timestamp < endOfDay
                }

                DispatchQueue.main.async {
                    // Step 3 & 4: Update UI based on history data
                    if todayHistory.isEmpty {
                        let recentHistory = allHistory.filter { history in
                            history.exerciseName == exercise.name
                        }
                        if let lastHistory = recentHistory.first {
                            currentWeight = lastHistory.weight
                            currentReps = lastHistory.reps
                            currentRPE = lastHistory.rpe
                        } else {
                            // No history, set to zero
                            currentWeight = 0
                            currentReps = 0
                            currentRPE = 0
                        }
                    } else {
                        if let lastHistory = todayHistory.first {
                            currentWeight = lastHistory.weight
                            currentReps = lastHistory.reps
                            currentRPE = lastHistory.rpe
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to load current values: \(error)")
                    // In case of error, reset to zero on main thread
                    currentWeight = 0
                    currentReps = 0
                    currentRPE = 0
                }
            }
        }
    }

    // Optimized saveExerciseHistory with DispatchQueue
    private func saveExerciseHistory() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Create new ExerciseHistory using exerciseName (String)
            let newHistory = ExerciseHistory(exerciseName: exercise.name, weight: currentWeight, reps: currentReps, rpe: currentRPE)
            modelContext.insert(newHistory)

            do {
                try modelContext.save()

                DispatchQueue.main.async {
                    // Recalculate set count after saving on main thread
                    calculateSetCountForToday()
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to save exercise history: \(error)")
                }
            }
        }
    }

    // Optimized calculateSetCountForToday with DispatchQueue
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
                let filteredHistory = todayHistory.filter { $0.exerciseName == exercise.name }

                DispatchQueue.main.async {
                    // Update setCount on the main thread
                    setCount = filteredHistory.count
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to calculate set count: \(error)")
                    setCount = 0
                }
            }
        }
    }
}
