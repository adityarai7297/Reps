import SwiftUI
import FirebaseFirestore

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
    
    @State private var exerciseStates: [ExerciseState] = [
        ExerciseState(exerciseName: "Bench Press", lastWeightValue: 100, lastRepValue: 4, lastRPEValue: 50, setCount: 0, showCheckmark: false),
        ExerciseState(exerciseName: "Squat", lastWeightValue: 100, lastRepValue: 4, lastRPEValue: 50, setCount: 0, showCheckmark: false),
        ExerciseState(exerciseName: "Deadlift", lastWeightValue: 100, lastRepValue: 4, lastRPEValue: 50, setCount: 0, showCheckmark: false),
        ExerciseState(exerciseName: "Bicep Curl", lastWeightValue: 100, lastRepValue: 4, lastRPEValue: 50, setCount: 0, showCheckmark: false)
    ]
    
    @State private var currentIndex: Int = 0
    @State private var showExerciseListView: Bool = false

    var body: some View {
        let colors: [Color] = [Color(hex: "d4e09b"),
                               Color(hex: "f6f4d2"),
                               Color(hex: "cbdfbd"),
                               Color(hex: "f19c79")]

        ZStack {
            VerticalPager(pageCount: exerciseStates.count, currentIndex: $currentIndex) {
                ForEach(exerciseStates.indices, id: \.self) { index in
                    ExerciseView(
                        state: $exerciseStates[index],
                        exerciseName: $exerciseStates[index].exerciseName,
                        weightWheelConfig: weightWheelConfig,
                        repWheelConfig: repWheelConfig,
                        RPEWheelConfig: exertionWheelConfig,
                        color: colors[index % colors.count]
                    )
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showExerciseListView = true
                    }) {
                        Image(systemName: "rectangle.stack")
                            .resizable()
                            .frame(width: 30, height: 50)
                            .foregroundColor(Color.black)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showExerciseListView) {
            ExerciseListView(exerciseStates: $exerciseStates)
        }
    }
}

struct ExerciseListView: View {
    @Binding var exerciseStates: [ExerciseState]
    @State private var newExerciseName: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add New Exercise")) {
                        TextField("Exercise Name", text: $newExerciseName)
                        Button("Add Exercise") {
                            if !newExerciseName.isEmpty {
                                let newExercise = ExerciseState(
                                    exerciseName: newExerciseName,
                                    lastWeightValue: 0,
                                    lastRepValue: 0,
                                    lastRPEValue: 0,
                                    setCount: 0,
                                    showCheckmark: false
                                )
                                exerciseStates.append(newExercise)
                                newExerciseName = ""
                            }
                        }
                    }
                    
                    Section(header: Text("My Exercises")) {
                        ForEach(exerciseStates.indices, id: \.self) { index in
                            HStack {
                                Text(exerciseStates[index].exerciseName)
                                Spacer()
                                Button(action: {
                                    exerciseStates.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle()) // Ensure only the icon is tappable
                                
                                Image(systemName: "line.horizontal.3")
                                    .padding(.leading)
                                
                            }
                        }
                        .onMove(perform: move)
                    }
                }
                .navigationTitle("Manage Exercises")
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
            .preferredColorScheme(.dark) // Force dark mode only here
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        exerciseStates.move(fromOffsets: source, toOffset: destination)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00ff00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000ff) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    ContentView()
}

// Your existing ExerciseView and other related code here...
