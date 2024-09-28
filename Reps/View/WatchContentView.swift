import SwiftUI
import WatchKit

struct WatchContentView: View {
    @State private var currentIndex: Int = 0
    @State private var currentMode: PickerMode = .weight
    @State private var currentWeight: CGFloat = 0
    @State private var currentReps: CGFloat = 0
    @State private var currentRPE: CGFloat = 0
    @State private var setCount: Int = 0
    @State private var exercises: [Exercise] = [
        Exercise(name: "Squat"),
        Exercise(name: "Bench Press"),
        Exercise(name: "Deadlift")
    ]
    
    let weightWheelConfig = WheelPicker.Config(count: 100, steps: 10, spacing: 7, multiplier: 5)
    let repWheelConfig = WheelPicker.Config(count: 100, steps: 1, spacing: 50, multiplier: 1)
    let exertionWheelConfig = WheelPicker.Config(count: 10, steps: 1, spacing: 50, multiplier: 10)

    var body: some View {
        VStack {
            if exercises.isEmpty {
                Text("Add exercises")
                    .font(.headline)
            } else {
                Text(exercises[currentIndex].name)
                    .font(.title2)
                    .padding(.top)
                
                Spacer()
                
                // Display picker based on the mode
                PickerView(currentMode: currentMode,
                           weight: $currentWeight,
                           reps: $currentReps,
                           rpe: $currentRPE,
                           weightConfig: weightWheelConfig,
                           repConfig: repWheelConfig,
                           rpeConfig: exertionWheelConfig)

                Spacer()

                HStack {
                    Text("Sets: \(setCount)")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing)
                }
            }
        }
        .focusable(true)
        .digitalCrownRotation($currentIndex, from: 0, through: exercises.count - 1, by: 1, sensitivity: .medium, isContinuous: false)
        .gesture(DragGesture().onEnded { value in
            if value.translation.width < 0 {
                cycleModeForward()
            } else {
                cycleModeBackward()
            }
        })
        .onLongPressGesture {
            recordSet()
        }
        .navigationTitle("Workout")
    }
    
    // Cycle through modes: Weight -> Reps -> RPE
    private func cycleModeForward() {
        if currentMode == .weight {
            currentMode = .reps
        } else if currentMode == .reps {
            currentMode = .rpe
        } else {
            currentMode = .weight
        }
    }
    
    private func cycleModeBackward() {
        if currentMode == .rpe {
            currentMode = .reps
        } else if currentMode == .reps {
            currentMode = .weight
        } else {
            currentMode = .rpe
        }
    }

    // Record a set and increase the set count
    private func recordSet() {
        setCount += 1
    }
}

enum PickerMode {
    case weight, reps, rpe
}

struct PickerView: View {
    var currentMode: PickerMode
    @Binding var weight: CGFloat
    @Binding var reps: CGFloat
    @Binding var rpe: CGFloat
    let weightConfig: WheelPicker.Config
    let repConfig: WheelPicker.Config
    let rpeConfig: WheelPicker.Config

    var body: some View {
        VStack {
            switch currentMode {
            case .weight:
                VStack {
                    Text("Weight")
                    WheelPicker(config: weightConfig, value: $weight)
                }
            case .reps:
                VStack {
                    Text("Reps")
                    WheelPicker(config: repConfig, value: $reps)
                }
            case .rpe:
                VStack {
                    Text("RPE")
                    WheelPicker(config: rpeConfig, value: $rpe)
                }
            }
        }
    }
}

struct Exercise {
    let name: String
}
