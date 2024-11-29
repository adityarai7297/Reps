import SwiftUI
import SwiftData

struct ExerciseView: View {
    @Binding var exercise: Exercise // No need for optional here
    @Binding var refreshTrigger: Bool
    @State private var showCheckmark: Bool = false
    @State private var showingHistory = false
    @Environment(\.modelContext) private var modelContext
    @State private var currentWeight: CGFloat = 0
    @State private var currentReps: CGFloat = 0
    @State private var currentRPE: CGFloat = 0
    @State private var setCount: Int = 0
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    let weightWheelConfig: WheelPicker.Config
    let repWheelConfig: WheelPicker.Config
    let RPEWheelConfig: WheelPicker.Config
    let color: Color
    let userId: String
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack {
            Spacer()

            Text(exercise.name)
                .font(.title)
                .fontWeight(.medium)
                .padding(.horizontal)
                .padding(.top, 40)
                .frame(width: UIScreen.main.bounds.width / 1.4)
                .foregroundColor(themeManager.textColor)

            Spacer()

            Rectangle()
                .fill(themeManager.separatorColor)
                .frame(height: 0.2)

            Spacer()

            // **Weight Picker Section**
            VStack(spacing: 10) {
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text("\(currentWeight, specifier: "%.1f")")
                        .font(.largeTitle.bold())
                        .contentTransition(.numericText(value: currentWeight))
                        .animation(.easeInOut(duration: 0.2), value: currentWeight)
                        .foregroundColor(themeManager.textColor)

                    Text("lbs")
                        .font(.title2)
                        .fontWeight(.light)
                        .textScale(.secondary)
                        .foregroundColor(themeManager.secondaryTextColor)
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
                        .foregroundColor(themeManager.textColor)

                    Text("reps")
                        .font(.title2)
                        .fontWeight(.light)
                        .textScale(.secondary)
                        .foregroundColor(themeManager.secondaryTextColor)
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
                        .foregroundColor(themeManager.textColor)

                    Text("% RPE")
                        .font(.title2)
                        .fontWeight(.light)
                        .textScale(.secondary)
                        .foregroundColor(themeManager.secondaryTextColor)
                }

                WheelPicker(config: RPEWheelConfig, value: $currentRPE)
                    .frame(height: 60)
            }

            Spacer()

            // **Set Button Section**
            HStack(spacing: 15) {
                SetButton(
                    showCheckmark: $showCheckmark,
                    setCount: $setCount,
                    action: {
                        saveExerciseHistory()
                    }
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(x: UIScreen.main.bounds.width / 12)

                HStack(spacing: 5) {
                    Text("\(setCount)")
                        .font(.title)
                        .foregroundColor(themeManager.textColor)

                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .opacity(setCount > 0 ? 1 : 0)
                .animation(.spring(response: 0.3), value: showCheckmark)
                .offset(x: -UIScreen.main.bounds.width / 8)
                .onTapGesture {
                    impactFeedback.impactOccurred()
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
        }
        .padding(.horizontal)
        .foregroundColor(.black)
        .background(color)
        .onAppear {
            loadCurrentValues()
            calculateSetCountForToday()
        }
        // Recalculate set count when refreshTrigger changes
        .onChange(of: refreshTrigger) {
            calculateSetCountForToday()
        }
    }

    // **Data Fetching and Saving Methods**

    private func loadCurrentValues() {
        guard !exercise.name.isEmpty else { return }
        
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
        guard !exercise.name.isEmpty else { return }
        
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
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to save exercise history: \(error)")
                }
            }
        }
    }

    private func calculateSetCountForToday() {
        // Since exercise is non-optional, we can directly check if the name is empty
        guard !exercise.name.isEmpty else {
            print("No valid exercise to calculate set count.")
            setCount = 0
            return
        }
        
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
