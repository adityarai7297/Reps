import SwiftUI

struct MenuView: View {
    @Binding var showExerciseListView: Bool
    @Binding var userId: String
    @Binding var exerciseStates: [ExerciseState]
    @Binding var currentIndex: Int

    var body: some View {
        VStack {
            Button(action: {
                showExerciseListView.toggle()
            }) {
                Text("Manage Exercises")
            }
            .padding()
            .background(Color.clear)
            .foregroundColor(Color.black)

            Button(action: {
                // Action for the button
            }) {
                Text("Logout")
            }
            .padding()
            .background(Color.clear)
            .foregroundColor(Color.black)

            // Add more menu items here

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showExerciseListView) {
            ExerciseListView(
                exerciseStates: $exerciseStates,
                currentIndex: $currentIndex,
                userId: userId
            )
        }
    }
}
