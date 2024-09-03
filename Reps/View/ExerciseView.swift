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
                    ExerciseHistoryView(exerciseName: exercise.name, date: Date(), onDelete: {
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

        // Fetch all ExerciseHistory records for the current day
        let fetchRequest = FetchDescriptor<ExerciseHistory>(
            predicate: #Predicate { history in
                history.timestamp >= startOfDay && history.timestamp < endOfDay
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)] // Sort by timestamp in descending order
        )
        
        do {
            // Fetch the history for the entire day
            let todayHistory = try modelContext.fetch(fetchRequest)
            
            // Filter history by the specific exercise name
            let filteredHistory = todayHistory.filter { $0.exercise.name == exercise.name }
            
            // Set the current values to the most recent history entry
            if let lastHistory = filteredHistory.first {
                currentWeight = lastHistory.weight
                currentReps = lastHistory.reps
                currentRPE = lastHistory.rpe
            } else {
                // If no history exists, default to zero
                currentWeight = 0
                currentReps = 0
                currentRPE = 0
            }
        } catch {
            print("Failed to load current values: \(error)")
            currentWeight = 0
            currentReps = 0
            currentRPE = 0
        }
    }

    private func saveExerciseHistory() {
        let newHistory = ExerciseHistory(exercise: exercise, weight: currentWeight, reps: currentReps, rpe: currentRPE)
        modelContext.insert(newHistory)

        do {
            try modelContext.save()
            calculateSetCountForToday() // Recalculate set count after saving
        } catch {
            print("Failed to save exercise history: \(error)")
        }
    }

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
            let filteredHistory = todayHistory.filter { $0.exercise.name == exercise.name }
            setCount = filteredHistory.count
        } catch {
            print("Failed to calculate set count: \(error)")
            setCount = 0
        }
    }
}
