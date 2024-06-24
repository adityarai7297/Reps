import SwiftUI

struct ContentView: View {
    @State private var weightWheelConfig: WheelPicker.Config = .init(
        count: 100,
        steps: 20,
        spacing: 10,
        multiplier: 10
    )
    @State private var repWheelConfig: WheelPicker.Config = .init(
        count: 30,
        steps: 1,
        spacing: 50,
        multiplier: 1
    )
    @State private var weightValue: CGFloat = 180
    @State private var repValue: CGFloat = 1
    var body: some View {
        NavigationStack {
            VStack {
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
            }
            
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
        }
            .navigationTitle("Wheel Picker")
        }
    }


#Preview {
    ContentView()
}
