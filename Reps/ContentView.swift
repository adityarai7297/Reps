import SwiftUI

struct ContentView: View {
    @State private var weightWheelConfig: WheelPicker.Config = .init(
        count: 100,
        steps: 20,
        spacing: 8,
        multiplier: 10
    )
    @State private var repWheelConfig: WheelPicker.Config = .init(
        count: 100,
        steps: 1,
        spacing: 50,
        multiplier: 1
    )
    @State private var weightValue: CGFloat = 100 // starting positions of wheel
    @State private var repValue: CGFloat = 4 // starting positions of wheel
    @State private var storedValue1: CGFloat = 0
    @State private var storedValue2: CGFloat = 0
    var body: some View {
        NavigationStack {
            VStack {
                // write exercise name here
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
                .padding(.vertical, 30)
                
                WheelPicker(config: weightWheelConfig, value: $weightValue)
                    .frame(height: 60)
                
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
                .padding(.vertical, 30)
                
                WheelPicker(config: repWheelConfig, value: $repValue)
                    .frame(height: 60)
                
                Button(action: {
                                storedValue1 = weightValue
                                storedValue2 = repValue
                            }) {
                                Text("Store Value")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Text("Stored Values: \(String(format: "%.1f", storedValue1)) lbs, \(Int(storedValue2)) reps")
                                .padding()
            }
        }
            .navigationTitle("Wheel Picker")
        }
    }


#Preview {
    ContentView()
}
