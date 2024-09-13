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
            Spacer(minLength: 40)

            Text(exercise.name)
                .font(.largeTitle)
                .fontWeight(.medium)

            Spacer(minLength: 40)

            Rectangle()
                .fill(Color.black)
                .frame(height: 0.2)

            Spacer(minLength: 40)

            // **Weight Picker Section**
            VStack(spacing: 10) {
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

            Spacer(minLength: 40)

            // **Reps Picker Section**
            VStack(spacing: 10) {
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text("\(currentReps, specifier: "%.0f")")
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

            Spacer(minLength: 40)

            // **RPE Picker Section**
            VStack(spacing: 10) {
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text("\(currentRPE, specifier: "%.0f")")
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

            Spacer()

            // **Set Button Section**
            HStack(spacing: 15) {
                SetButton(showCheckmark: $showCheckmark, setCount: $setCount, action: {
                    saveExerciseHistory()
                })

                HStack(spacing: 5) {
                    Text("\(setCount)")
                        .font(.title)

                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .opacity(setCount > 0 ? 1 : 0)
                .animation(.spring(response: 0.3), value: showCheckmark)
                .onTapGesture {
                    showingHistory.toggle()
                }
                .sheet(isPresented: $showingHistory) {
                    ExerciseHistoryView(exerciseName: exercise.name, onDelete: {
                        calculateSetCountForToday()
                    })
                    .environment(\.modelContext, modelContext)
                }
            }
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .center) // Center the HStack
        }
        .padding(.horizontal)
        .foregroundColor(.black)
        .background(color)
        .onAppear {
            loadCurrentValues()
            calculateSetCountForToday()
        }
    }

    // **Data Fetching and Saving Methods**

    private func loadCurrentValues() {
        let exerciseName = exercise.name

        DispatchQueue.global(qos: .userInitiated).async {
            let predicate = #Predicate<ExerciseHistory> { history in
                history.exerciseName == exerciseName
            }

            let fetchRequest = FetchDescriptor<ExerciseHistory>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )

            do {
                let fetchedHistory = try modelContext.fetch(fetchRequest)

                DispatchQueue.main.async {
                    if let lastHistory = fetchedHistory.first {
                        currentWeight = lastHistory.weight
                        currentReps = lastHistory.reps
                        currentRPE = lastHistory.rpe
                    } else {
                        currentWeight = 0
                        currentReps = 0
                        currentRPE = 0
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to load current values: \(error)")
                    currentWeight = 0
                    currentReps = 0
                    currentRPE = 0
                }
            }
        }
    }

    private func saveExerciseHistory() {
        let exerciseName = exercise.name

        DispatchQueue.global(qos: .userInitiated).async {
            let newHistory = ExerciseHistory(
                exerciseName: exerciseName,
                weight: currentWeight,
                reps: currentReps,
                rpe: currentRPE
            )
            modelContext.insert(newHistory)

            do {
                try modelContext.save()

                DispatchQueue.main.async {
                    calculateSetCountForToday()
                    // Handle any additional logic if needed
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to save exercise history: \(error)")
                }
            }
        }
    }

    private func calculateSetCountForToday() {
        let exerciseName = exercise.name
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        DispatchQueue.global(qos: .userInitiated).async {
            let predicate = #Predicate<ExerciseHistory> { history in
                history.exerciseName == exerciseName &&
                history.timestamp >= startOfDay && history.timestamp < endOfDay
            }

            let fetchRequest = FetchDescriptor<ExerciseHistory>(
                predicate: predicate
            )

            do {
                let todayHistory = try modelContext.fetch(fetchRequest)

                DispatchQueue.main.async {
                    setCount = todayHistory.count
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
