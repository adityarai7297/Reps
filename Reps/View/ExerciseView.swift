import SwiftUI

struct ExerciseView: View {
    let exerciseName: String
    @Binding var weightValue: CGFloat
    @Binding var repValue: CGFloat
    @Binding var exertionValue: CGFloat
    @Binding var setCount: Int
    @Binding var showCheckmark: Bool
    let weightWheelConfig: WheelPicker.Config
    let repWheelConfig: WheelPicker.Config
    let exertionWheelConfig: WheelPicker.Config

    var body: some View {
        VStack{
            VStack {
                Text(exerciseName)
                    .font(.largeTitle.bold())
                
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(.gray)
                
                Spacer().frame(height: 60)
                
                HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                    Text(verbatim: "\(weightValue)")
                        .font(.largeTitle.bold())
                        .contentTransition(.numericText(value: weightValue))
                        .animation(.snappy, value: weightValue)
                    
                    Text("lbs")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)
                })
                
                WheelPicker(config: weightWheelConfig, value: $weightValue)
                    .frame(height: 60)
                
                Spacer().frame(height: 40)
                
                HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                    Text(verbatim: "\(Int(repValue))")
                        .font(.largeTitle.bold())
                        .contentTransition(.numericText(value: repValue))
                        .animation(.snappy, value: repValue)
                    
                    Text("reps")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)
                })
                
                WheelPicker(config: repWheelConfig, value: $repValue)
                    .frame(height: 60)
                
                Spacer().frame(height: 40)
                
                HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                    Text(verbatim: "\(Int(exertionValue))")
                        .font(.largeTitle.bold())
                        .contentTransition(.numericText(value: exertionValue))
                        .animation(.snappy, value: exertionValue)
                    
                    Text("%  RPE")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)
                })
                
                WheelPicker(config: exertionWheelConfig, value: $exertionValue)
                    .frame(height: 60)
            }
            .offset(y: showCheckmark ? -60 : 0) // Adjust offset value to move elements up
            
            Spacer().frame(height: 40)
            
            HStack {
                Spacer().frame(width: 12)
                SetButton(showCheckmark: $showCheckmark, setCount: $setCount, action: {
                    setCount += 1
                    print("Weight: \(weightValue) lbs")
                    print("Reps: \(repValue)")
                    print("Exertion: \(exertionValue) % RPE")
                })
                Spacer().frame(width: 12)
                Text("\(setCount)")
                    .font(.title)
                    .opacity(setCount > 0 ? 1 : 0)
            }
            
            Spacer().frame(height: 40)
            
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        
}
