import SwiftUI
import FirebaseFirestore

struct ExerciseView: View {
    @Binding var state: ExerciseState
    @Binding var exerciseName: String
    let weightWheelConfig: WheelPicker.Config
    let repWheelConfig: WheelPicker.Config
    let RPEWheelConfig: WheelPicker.Config
    let color: Color

    var body: some View {
        VStack {
            VStack {
                Spacer().frame(height: 40)
                Text(exerciseName)
                    .font(.largeTitle.bold())
                Spacer().frame(height: 40)
                
                Rectangle()
                    .frame(height: 0.3)
                    //.foregroundColor(.gray)
                
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
                            //.foregroundStyle(.gray)
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
                            //.foregroundStyle(.gray)
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
                            //.foregroundStyle(.gray)
                    })
                    
                    WheelPicker(config: RPEWheelConfig, value: $state.lastRPEValue)
                        .frame(height: 60)
                    
                }
                
            }
            .offset(y: state.showCheckmark ? -60 : 0) // Adjust offset value to move elements up
            
            Spacer().frame(height: 60)
            
            HStack {
                Spacer().frame(width: 100)
                SetButton(showCheckmark: $state.showCheckmark, setCount: $state.setCount, action: {
                    state.setCount += 1
                    print("Exercise: \(state.exerciseName)")
                    print("Weight: \(state.lastWeightValue) lbs")
                    print("Reps: \(state.lastRepValue)")
                    print("RPE: \(state.lastRPEValue) % RPE")
                    
                    saveExerciseData(exerciseName: state.exerciseName, weight: state.lastWeightValue, reps: state.lastRepValue, RPE: state.lastRPEValue)
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
            }
            
            //Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
        .edgesIgnoringSafeArea(.all)
    }
}

func saveExerciseData(exerciseName: String, weight: Double, reps: Double, RPE: Double) {
    let db = Firestore.firestore()
    db.collection("sets").addDocument(data: [
        "exerciseName": exerciseName,
        "weight": weight,
        "reps": reps,
        "RPE": RPE,
        "timestamp": Timestamp()
    ]) { error in
        if let error = error {
            print("Error adding document: \(error)")
        } else {
            print("Document added successfully")
        }
    }
}

#Preview {
    ContentView()
}
