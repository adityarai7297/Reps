import SwiftUI
import SwiftData

struct ExerciseView: View {
    @Binding var state: ExerciseState
    @State private var showCheckmark: Bool = false
    @State private var showingHistory = false
    @Binding var exerciseName: String
    @Environment(\.modelContext) private var modelContext
    let weightWheelConfig: WheelPicker.Config
    let repWheelConfig: WheelPicker.Config
    let RPEWheelConfig: WheelPicker.Config
    let color: Color
    let userId: String
    

    var body: some View {
        VStack {
            VStack {
                Spacer().frame(height: 40)
                Text(exerciseName)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                Spacer().frame(height: 40)

                Rectangle()
                                .fill(Color.black)
                                .frame(width: UIScreen.main.bounds.width, height: 0.2)

                Spacer().frame(height: 60)

                VStack{
                    HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                        Text(verbatim: "\(state.lastWeightValue)")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: state.lastWeightValue))
                            .animation(.snappy, value: state.lastWeightValue)

                        Text("lbs")
                            .font(.title2)
                            .fontWeight(.light)
                            .textScale(.secondary)
                    })

                    WheelPicker(config: weightWheelConfig, value: $state.lastWeightValue)
                        .frame(height: 60)
                }

                Spacer().frame(height: 40)

                VStack{
                    HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                        Text(verbatim: "\(Int(state.lastRepValue))")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: state.lastRepValue))
                            .animation(.snappy, value: state.lastRepValue)

                        Text("reps")
                            .font(.title2)
                            .fontWeight(.light)
                            .textScale(.secondary)
                    })

                    WheelPicker(config: repWheelConfig, value: $state.lastRepValue)
                        .frame(height: 60)
                }

                Spacer().frame(height: 40)

                VStack{
                    HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                        Text(verbatim: "\(Int(state.lastRPEValue))")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: state.lastRPEValue))
                            .animation(.snappy, value: state.lastRPEValue)

                        Text("%  RPE")
                            .font(.title2)
                            .fontWeight(.light)
                            .textScale(.secondary)
                    })

                    WheelPicker(config: RPEWheelConfig, value: $state.lastRPEValue)
                        .frame(height: 60)
                }
            }
            .offset(y: showCheckmark ? -60 : 0)

            Spacer().frame(height: 60)

            HStack {
                Spacer().frame(width: 100)
                SetButton(showCheckmark: $showCheckmark, setCount: $state.setCount, action: {
                    state.setCount += 1
                    saveExerciseData(state: state)
                })
                Spacer().frame(width: 30)
                HStack{
                    Text("\(state.setCount)")
                        .font(.title)

                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)

                }
                .opacity(state.setCount > 0 ? 1 : 0)
                .onTapGesture {
                                    showingHistory.toggle()
                                }
                                .sheet(isPresented: $showingHistory) {
                                    ExerciseHistoryView(exerciseName: exerciseName, date: Date())
                                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
        .edgesIgnoringSafeArea(.all)
    }
    
    func saveExerciseData(state: ExerciseState) {
        let context = modelContext  // Obtain the current model context
        do {
            state.timestamp = Date() // Update the timestamp to the current date and time
            try context.save() // Save the updated state to the persistent store
        } catch {
            print("Failed to save exercise state: \(error)")
        }
    }
}


