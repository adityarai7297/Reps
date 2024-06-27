import SwiftUI

struct ContentView: View {
    @State private var weightWheelConfig: WheelPicker.Config = .init(
        count: 100,
        steps: 10,
        spacing: 7,
        multiplier: 5
    )
    @State private var repWheelConfig: WheelPicker.Config = .init(
        count: 100,
        steps: 1,
        spacing: 50,
        multiplier: 1
    )
    
    @State private var exertionWheelConfig: WheelPicker.Config = .init(
        count: 10,
        steps: 1,
        spacing: 50,
        multiplier: 10
    )
    
    @State private var weightValue: CGFloat = 100 // starting positions of wheel
    @State private var repValue: CGFloat = 4 // starting positions of wheel
    @State private var exertionValue: CGFloat = 50
    @State private var showCheckmark: Bool = false
    @State private var setCount: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Text("Bench Press")
                        .font(.largeTitle.bold())
                
                    Rectangle()
                        .frame(height: 1)
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
                
                HStack{
                    Spacer().frame(width: 12)
                    SetButton(showCheckmark: $showCheckmark, setCount: $setCount, action: {
                        // this would be replaced by stateful operations
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
                
            }
        }
        .navigationTitle("Wheel Picker")
    }
}

#Preview {
    ContentView()
}
