import SwiftUI
import SwiftData

struct ManageExercisesView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var exercises: [Exercise]
    @State private var newExerciseName: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(exercises.indices, id: \.self) { index in
                    HStack {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.gray)
                        TextField("Exercise Name", text: Binding(
                            get: { exercises[index].name },
                            set: { exercises[index].name = $0 }
                        ))
                        Spacer()
                        Button(action: {
                            deleteExercise(at: index)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                .onMove(perform: moveExercise) // Make the list draggable without EditButton
                
                HStack {
                    TextField("New Exercise Name", text: $newExerciseName)
                    Spacer()
                    Button(action: addExercise) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationBarTitle("Manage Exercises", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                saveExercisesOrder()
                presentationMode.wrappedValue.dismiss()
            })
            .environment(\.editMode, .constant(.active)) // Activate drag-and-drop by default
        }
    }

    private func addExercise() {
        guard !newExerciseName.isEmpty else { return }

        let newExercise = Exercise(name: newExerciseName)
        exercises.append(newExercise)
        modelContext.insert(newExercise)
        saveContext()
        newExerciseName = ""
    }

    private func deleteExercise(at index: Int) {
        let exercise = exercises.remove(at: index)
        modelContext.delete(exercise)
        saveContext()
    }

    private func moveExercise(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
        saveContext()
    }

    private func saveExercisesOrder() {
        saveContext()
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
