import SwiftUI
import SwiftData

@MainActor
struct ExerciseView: View {
    @Binding var exercise: Exercise
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
    @AppStorage("hasShownFirstExerciseHints") private var hasShownFirstExerciseHints = false
    @State private var currentHintStep = 0
    @State private var showHint = false
    @State private var isAnimatingIcon = false

    private var hintOffset: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        // For smaller phones (iPhone SE, mini), use smaller offset
        if screenHeight <= 667 {
            return screenHeight * 0.18 // 18% of screen height
        }
        // For regular and larger phones
        return screenHeight * 0.22 // 22% of screen height
    }

    private var repsHintOffset: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight <= 667 {
            return screenHeight * 0.18
        }
        return screenHeight * 0.22
    }

    private var rpeHintOffset: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight <= 667 {
            return screenHeight * 0.16
        }
        return screenHeight * 0.20
    }

    var body: some View {
        ZStack {
            VStack {
                Spacer()

                Text(exercise.name)
                    .font(.title)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.top, 40)
                    .frame(width: UIScreen.main.bounds.width / 1.4)
                    .foregroundColor(themeManager.textColor)
                    .blur(radius: showHint ? 3 : 0)

                Spacer()

                Rectangle()
                    .fill(themeManager.separatorColor)
                    .frame(height: 0.2)
                    .blur(radius: showHint ? 3 : 0)

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
                    .blur(radius: showHint && currentHintStep != 1 ? 3 : 0)

                    WheelPicker(config: weightWheelConfig, value: $currentWeight)
                        .frame(height: 60)
                        .blur(radius: showHint && currentHintStep != 1 ? 3 : 0)
                        .allowsHitTesting(currentHintStep == 1 || !showHint)
                }
                .overlay(alignment: .bottom) {
                    if showHint && currentHintStep == 1 {
                        HintView(
                            icon: "hand.draw",
                            message: "Select weight to lift",
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    currentHintStep = 2
                                    impactFeedback.impactOccurred()
                                }
                            }
                        )
                        .offset(y: hintOffset)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
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
                    .blur(radius: showHint && currentHintStep != 2 ? 3 : 0)

                    WheelPicker(config: repWheelConfig, value: $currentReps)
                        .frame(height: 60)
                        .blur(radius: showHint && currentHintStep != 2 ? 3 : 0)
                        .allowsHitTesting(currentHintStep == 2 || !showHint)
                }
                .overlay(alignment: .bottom) {
                    if showHint && currentHintStep == 2 {
                        HintView(
                            icon: "hand.draw",
                            message: "How many repetitions\ndid you just do?",
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    currentHintStep = 3
                                    impactFeedback.impactOccurred()
                                }
                            }
                        )
                        .offset(y: repsHintOffset)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
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
                    .blur(radius: showHint && currentHintStep != 3 ? 3 : 0)

                    WheelPicker(config: RPEWheelConfig, value: $currentRPE)
                        .frame(height: 60)
                        .blur(radius: showHint && currentHintStep != 3 ? 3 : 0)
                        .allowsHitTesting(currentHintStep == 3 || !showHint)
                }
                .overlay(alignment: .bottom) {
                    if showHint && currentHintStep == 3 {
                        HintView(
                            icon: "hand.draw",
                            message: "What was the effort?",
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    showHint = false
                                    hasShownFirstExerciseHints = true
                                    impactFeedback.impactOccurred()
                                }
                            }
                        )
                        .offset(y: rpeHintOffset)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }

                Spacer()

                // **Set Button Section**
                HStack(spacing: 15) {
                    SetButton(
                        showCheckmark: $showCheckmark,
                        setCount: $setCount,
                        action: {
                            Task {
                                await saveExerciseHistory()
                                hasShownFirstExerciseHints = true
                            }
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .offset(x: UIScreen.main.bounds.width / 12)
                    .blur(radius: showHint ? 3 : 0)
                    .allowsHitTesting(!showHint)

                    HStack(spacing: 5) {
                        Text("\(setCount)")
                            .font(.title)
                            .foregroundColor(themeManager.textColor)

                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .foregroundColor(themeManager.navigationIconColor)
                            .frame(width: 24, height: 24)
                    }
                    .opacity(setCount > 0 ? 1 : 0)
                    .animation(.spring(response: 0.3), value: showCheckmark)
                    .offset(x: -UIScreen.main.bounds.width / 8)
                    .blur(radius: showHint ? 3 : 0)
                    .allowsHitTesting(!showHint)
                    .onTapGesture {
                        impactFeedback.impactOccurred()
                        showingHistory.toggle()
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal)
            .foregroundColor(.black)
            .background(color)
        }
        .sheet(isPresented: $showingHistory) {
            ExerciseHistoryView(exerciseName: exercise.name, onDelete: {
                Task {
                    await calculateSetCountForToday()
                }
            })
            .environment(\.modelContext, modelContext)
        }
        .onAppear {
            Task {
                await loadCurrentValues()
                await calculateSetCountForToday()
                
                // Show first hint only if it's the first exercise ever
                if !hasShownFirstExerciseHints {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.5)) {
                            currentHintStep = 1
                            showHint = true
                        }
                    }
                }
            }
        }
    }
    
    // **Data Fetching and Saving Methods**

    private func loadCurrentValues() async {
        guard !exercise.name.isEmpty else { return }
        let exerciseName = exercise.name
        
        do {
            let descriptor = FetchDescriptor<ExerciseHistory>(
                predicate: #Predicate<ExerciseHistory> { history in
                    history.exerciseName == exerciseName
                },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            
            let fetchedHistory = try modelContext.fetch(descriptor)
            
            if let lastHistory = fetchedHistory.first {
                currentWeight = lastHistory.weight
                currentReps = lastHistory.reps
                currentRPE = lastHistory.rpe
            } else {
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

    private func saveExerciseHistory() async {
        guard !exercise.name.isEmpty else { return }
        let exerciseName = exercise.name
        
        let newHistory = ExerciseHistory(
            exerciseName: exerciseName,
            weight: currentWeight,
            reps: currentReps,
            rpe: currentRPE
        )
        
        modelContext.insert(newHistory)
        
        do {
            try modelContext.save()
            await calculateSetCountForToday()
        } catch {
            print("Failed to save exercise history: \(error)")
        }
    }

    private func calculateSetCountForToday() async {
        guard !exercise.name.isEmpty else { 
            setCount = 0
            return 
        }
        let exerciseName = exercise.name
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<ExerciseHistory>(
            predicate: #Predicate<ExerciseHistory> { history in
                history.exerciseName == exerciseName &&
                history.timestamp >= startOfDay &&
                history.timestamp < endOfDay
            }
        )

        do {
            let todayHistory = try modelContext.fetch(descriptor)
            setCount = todayHistory.count
        } catch {
            setCount = 0
            print("Failed to calculate set count: \(error)")
        }
    }
}

// MARK: - Hint View
struct HintView: View {
    let icon: String
    let message: String
    var action: (() -> Void)? = nil
    @State private var isAnimatingIcon = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 38))
                .foregroundColor(.white)
                .offset(x: isAnimatingIcon ? -10 : 10)
                .animation(
                    Animation.easeInOut(duration: 1)
                        .repeatForever(autoreverses: true),
                    value: isAnimatingIcon
                )
                .onAppear {
                    isAnimatingIcon = true
                }
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                action?()
            }) {
                Text("Got it!")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.9))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .frame(width: 240)
    }
}
