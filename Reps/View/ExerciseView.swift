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
                            .animation(.snappy, value: currentWeight) // Ensure this is properly applied

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
                        Text("\(Int(currentReps))")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: currentReps))
                            .animation(.snappy, value: currentReps) // Ensure this is properly applied

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
                        Text("\(Int(currentRPE))")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: currentRPE))
                            .animation(.snappy, value: currentRPE) // Ensure this is properly applied

                        Text("%  RPE")
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
                loadCurrentValues()
            }

            Spacer().frame(height: 60)

            HStack {
                Spacer().frame(width: 100)
                SetButton(showCheckmark: $showCheckmark, setCount: .constant(exercise.history.count + 1), action: {
                    saveExerciseHistory()
                })
                Spacer().frame(width: 30)
                HStack {
                    Text("\(exercise.history.count)")
                        .font(.title)

                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
                .opacity(exercise.history.count > 0 ? 1 : 0)
                .onTapGesture {
                    showingHistory.toggle()
                }
                .sheet(isPresented: $showingHistory) {
                    ExerciseHistoryView(exerciseName: exercise.name, date: Date())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func loadCurrentValues() {
        if let lastHistory = exercise.history.last {
            withAnimation(.snappy) {
                currentWeight = lastHistory.weight
                currentReps = lastHistory.reps
                currentRPE = lastHistory.rpe
            }
        } else {
            currentWeight = 0
            currentReps = 0
            currentRPE = 0
        }
    }

    private func saveExerciseHistory() {
        let newHistory = ExerciseHistory(exercise: exercise, weight: currentWeight, reps: currentReps, rpe: currentRPE)
        exercise.history.append(newHistory)
        
        modelContext.insert(newHistory)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save exercise history: \(error)")
        }
    }
}
