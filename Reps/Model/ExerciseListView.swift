import SwiftUI
import FirebaseFirestore

struct ExerciseListView: View {
    @Binding var exerciseStates: [ExerciseState]
    @Binding var currentIndex: Int
    @State private var newExerciseName: String = ""
    @Environment(\.presentationMode) var presentationMode
    let userId: String
    
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
                                addExerciseToFirebase(userId: userId, exerciseName: newExerciseName)
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
                                    removeExercise(userId: userId, exerciseName: exerciseStates[index].exerciseName, index: index)
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
    
    func addExerciseToFirebase(userId: String, exerciseName: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.collection("exercises").document(exerciseName).setData([
            "exerciseName": exerciseName
        ]) {
            error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }
    
    func removeExercise(userId: String, exerciseName: String, index: Int) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.collection("exercises").document(exerciseName).delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document removed successfully")
                exerciseStates.remove(at: index)
                // Ensure currentIndex is within bounds
                if currentIndex >= exerciseStates.count {
                    currentIndex = max(0, exerciseStates.count - 1)
                }
            }
        }
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    @State static var exerciseStates = [
        ExerciseState(exerciseName: "Exercise A", lastWeightValue: 0, lastRepValue: 0, lastRPEValue: 0, setCount: 0, showCheckmark: false),
        ExerciseState(exerciseName: "Exercise B", lastWeightValue: 0, lastRepValue: 0, lastRPEValue: 0, setCount: 0, showCheckmark: false)
    ]
    @State static var currentIndex = 0

    static var previews: some View {
        ExerciseListView(exerciseStates: $exerciseStates, currentIndex: $currentIndex, userId: "your_user_id")
    }
}
