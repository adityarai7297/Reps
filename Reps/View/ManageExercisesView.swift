import SwiftUI
import SwiftData

struct ManageExercisesView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var refreshTrigger: Bool // Binding to trigger a re-render in the parent view
    @Binding var exercises: [Exercise]
    @State private var newExerciseName: String = ""
    @State private var editingExercise: Exercise?

    var body: some View {
        NavigationView {
            VStack {
                // Text Field to add new exercise
                HStack {
                    TextField("New Exercise", text: $newExerciseName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button(action: {
                        addExercise()
                        newExerciseName = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 24))
                    }
                    .padding(.trailing)
                }
                .padding(.top)

                // List of exercises
                List {
                    ForEach(exercises) { exercise in
                        HStack {
                            if editingExercise == exercise {
                                TextField("Exercise Name", text: Binding(
                                    get: { exercise.name },
                                    set: { newName in
                                        exercise.name = newName
                                    }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    saveChanges(for: exercise)
                                }
                                .onDisappear {
                                    if editingExercise == exercise {
                                        saveChanges(for: exercise)
                                    }
                                }
                            } else {
                                Text(exercise.name)
                                    .onTapGesture {
                                        editingExercise = exercise
                                    }
                                    .contextMenu {
                                        Button("Edit") {
                                            editingExercise = exercise
                                        }
                                        Button("Delete", role: .destructive) {
                                            deleteExercise(exercise)
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Manage Exercises")
        }
    }

    private func addExercise() {
        guard !newExerciseName.isEmpty else { return }

        let newExercise = Exercise(name: newExerciseName)
        exercises.append(newExercise)
        modelContext.insert(newExercise)
        saveContext()
    }

    private func saveChanges(for exercise: Exercise) {
        if let index = exercises.firstIndex(of: exercise) {
            exercises[index].name = exercise.name
            editingExercise = nil
            saveContext()
        }
    }

    private func deleteExercise(_ exercise: Exercise) {
        guard let index = exercises.firstIndex(of: exercise) else { return }

        // Fetch all ExerciseHistory entries first, and filter them in-memory
        let historyFetchRequest = FetchDescriptor<ExerciseHistory>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)] // Fetch all and sort by timestamp
        )
        
        do {
            let allHistories = try modelContext.fetch(historyFetchRequest)
            
            // Filter histories by exercise name in-memory
            let historiesToDelete = allHistories.filter { $0.exerciseName == exercise.name }
            
            // Delete each filtered ExerciseHistory entry
            for history in historiesToDelete {
                modelContext.delete(history)
            }
            
            // Now delete the exercise itself
            modelContext.delete(exercise)
            exercises.remove(at: index)
            
            // Save the context to persist the deletions
            saveContext()

            // Trigger a view update to ensure the list refreshes properly
            self.exercises = Array(exercises) // Force reassign to trigger state update
            refreshTrigger.toggle()

        } catch {
            print("Failed to delete exercise or exercise history: \(error)")
        }
    }


    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
