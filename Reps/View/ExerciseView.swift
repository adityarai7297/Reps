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
                        .foregroundColor(.black)
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
        .background(color)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func loadCurrentValues() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Step 1: Fetch all ExerciseHistory records for this exercise
        let fetchRequest = FetchDescriptor<ExerciseHistory>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)] // Sort by timestamp in descending order
        )
        
        do {
            // Fetch all the exercise history records
            let allHistory = try modelContext.fetch(fetchRequest)
            
            // Step 2: Filter for the current exercise and today's date
            let todayHistory = allHistory.filter { history in
                history.exerciseName == exercise.name && history.timestamp >= startOfDay && history.timestamp < endOfDay
            }
            
            // Step 3: If no history exists for today, look for the most recent history from any previous day
            if todayHistory.isEmpty {
                let recentHistory = allHistory.filter { history in
                    history.exerciseName == exercise.name
                }
                
                // Step 4: Load the most recent history values if found, or set to zero if none exists
                if let lastHistory = recentHistory.first {
                    currentWeight = lastHistory.weight
                    currentReps = lastHistory.reps
                    currentRPE = lastHistory.rpe
                } else {
                    // No history at all, set to zero
                    currentWeight = 0
                    currentReps = 0
                    currentRPE = 0
                }
            } else {
                // If history exists for today, use the most recent entry from today
                if let lastHistory = todayHistory.first {
                    currentWeight = lastHistory.weight
                    currentReps = lastHistory.reps
                    currentRPE = lastHistory.rpe
                }
            }
        } catch {
            print("Failed to load current values: \(error)")
            // In case of error, set everything to zero
            currentWeight = 0
            currentReps = 0
            currentRPE = 0
        }
    }

    private func saveExerciseHistory() {
        // Create new ExerciseHistory using exerciseName (String) instead of Exercise (object)
        let newHistory = ExerciseHistory(exerciseName: exercise.name, weight: currentWeight, reps: currentReps, rpe: currentRPE)
        modelContext.insert(newHistory)

        do {
            try modelContext.save()
            calculateSetCountForToday() // Recalculate set count after saving
        } catch {
            print("Failed to save exercise history: \(error)")
        }
    }

    // Updated to use exerciseName directly
    private func calculateSetCountForToday() {
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
            setCount = filteredHistory.count
        } catch {
            print("Failed to calculate set count: \(error)")
            setCount = 0
        }
    }
}
