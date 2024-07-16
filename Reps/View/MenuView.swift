import SwiftUI

struct MenuView: View {
    @Binding var showExerciseListView: Bool
    @Binding var userId: String
    @Binding var exerciseStates: [ExerciseState]
    @Binding var currentIndex: Int

    var body: some View {
        VStack {
            Button(action: {
                // Action for the button
            }) {
                Text("Menu Item 1")
            }
            .padding()
            .background(Color.clear)
            .foregroundColor(Color.black)

            Button(action: {
                // Action for the button
            }) {
                Text("Menu Item 2")
            }
            .padding()
            .background(Color.clear)
            .foregroundColor(Color.black)

            // Add more menu items here

            Spacer()
        }
        .padding()
    }
}
