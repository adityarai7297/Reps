import SwiftUI

struct ExerciseView: View {
    let exerciseName: String
    @Binding var state: ExerciseState
    let weightWheelConfig: WheelPicker.Config
    let repWheelConfig: WheelPicker.Config
    let exertionWheelConfig: WheelPicker.Config

    var body: some View {
        VStack {
            VStack {
                Text(exerciseName)
                    .font(.largeTitle.bold())
                
                Rectangle()
                    .frame(height: 0.3)
                    .foregroundColor(.gray)
                
                Spacer().frame(height: 60)
                
                VStack{
                    HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                        Text(verbatim: "\(state.weightValue)")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: state.weightValue))
                            .animation(.snappy, value: state.weightValue)
                        
                        Text("lbs")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .textScale(.secondary)
                            .foregroundStyle(.gray)
                    })
                    
                    WheelPicker(config: weightWheelConfig, value: $state.weightValue)
                        .frame(height: 60)
                    
                }
                
                Spacer().frame(height: 40)
                
                VStack{
                    HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                        Text(verbatim: "\(Int(state.repValue))")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: state.repValue))
                            .animation(.snappy, value: state.repValue)
                        
                        Text("reps")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .textScale(.secondary)
                            .foregroundStyle(.gray)
                    })
                    
                    WheelPicker(config: repWheelConfig, value: $state.repValue)
                        .frame(height: 60)
                    
                }
                
                Spacer().frame(height: 40)
                
                VStack{
                    HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                        Text(verbatim: "\(Int(state.exertionValue))")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: state.exertionValue))
                            .animation(.snappy, value: state.exertionValue)
                        
                        Text("%  RPE")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .textScale(.secondary)
                            .foregroundStyle(.gray)
                    })
                    
                    WheelPicker(config: exertionWheelConfig, value: $state.exertionValue)
                        .frame(height: 60)
                    
                }
                
            }
            .offset(y: state.showCheckmark ? -60 : 0) // Adjust offset value to move elements up
            
            Spacer().frame(height: 40)
            
            HStack {
                Spacer().frame(width: 12)
                SetButton(showCheckmark: $state.showCheckmark, setCount: $state.setCount, action: {
                    state.setCount += 1
                    print("Weight: \(state.weightValue) lbs")
                    print("Reps: \(state.repValue)")
                    print("Exertion: \(state.exertionValue) % RPE")
                })
                Spacer().frame(width: 12)
                Text("\(state.setCount)")
                    .font(.title)
                    .opacity(state.setCount > 0 ? 1 : 0)
            }
            
            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
