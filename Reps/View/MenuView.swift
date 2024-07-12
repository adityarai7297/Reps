import SwiftUI

struct MenuView: View {
    @Binding var showExerciseListView: Bool
    @Binding var userId: String
    @Binding var exerciseStates:  [ExerciseState]
    @Binding var currentIndex: Int
    var body: some View {
        VStack {
            Button(action: {
                                   showExerciseListView = true
                               }) {
                Text("Manage Exercises")
                    .foregroundColor(.black)
                    .padding()
            }
            Button(action: {
                print("Button 2 clicked")
            }) {
                Text("Button 2")
                    .foregroundColor(.black)
                    .padding()
            }
            Button(action: {
                print("Button 3 clicked")
            }) {
                Text("Button 3")
                    .foregroundColor(.black)
                    .padding()
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
        .sheet(isPresented: $showExerciseListView) {
                   ExerciseListView(exerciseStates: $exerciseStates, currentIndex: $currentIndex, userId: userId)
               }
    }
}
