import SwiftUI
import SwiftData

struct ManageExercisesView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var refreshTrigger: Bool
    @Binding var exercises: [Exercise]
    @State private var newExerciseName: String = ""
    @State private var editingExercise: Exercise?
    @State private var showSuggestions: Bool = false
    @State private var suggestedExercises: [String] = []
    @State private var showDuplicateAlert: Bool = false  // State for showing duplicate alert
    
    let allPossibleExercises = [
        "Bench Press",
            "Incline Bench Press",
            "Decline Bench Press",
            "Chest Flyes",
            "Cable Crossovers",
            "Push-Ups",
            "Dumbbell Bench Press",
            "Dumbbell Flyes",
            
            // Back exercises
            "Deadlift",
            "Pull-Ups",
            "Chin-Ups",
            "Lat Pulldown",
            "Barbell Row",
            "Dumbbell Row",
            "T-Bar Row",
            "Cable Row",
            "Rack Pulls",
            "Face Pulls",
            "Hyperextensions",
            "Single Arm Lat Pulldown",
            
            // Shoulder exercises
            "Overhead Press (OHP)",
            "Arnold Press",
            "Lateral Raises",
            "Front Raises",
            "Rear Delt Flyes",
            "Cable Lateral Raises",
            "Dumbbell Shoulder Press",
            "Barbell Shoulder Press",
            "Cable Face Pulls",
            
            // Bicep exercises
            "Barbell Bicep Curl",
            "Dumbbell Bicep Curl",
            "Preacher Curl",
            "Hammer Curl",
            "Concentration Curl",
            "Cable Curl",
            "Incline Dumbbell Curl",
            
            // Tricep exercises
            "Tricep Dips",
            "Skull Crushers",
            "Close-Grip Bench Press",
            "Tricep Pushdowns",
            "Overhead Tricep Extension",
            "Dumbbell Kickbacks",
            "Cable Tricep Extension",
            
            // Leg exercises
            "Squats",
            "Front Squats",
            "Bulgarian Split Squats",
            "Leg Press",
            "Lunges",
            "Step-Ups",
            "Romanian Deadlift",
            "Leg Curls",
            "Leg Extensions",
            "Calf Raises",
            "Seated Calf Raises",
            "Hack Squat",
            "Sumo Deadlift",
            "Hip Thrusts",
            "Glute Bridge",
            "Goblet Squat",
            "Walking Lunges",
            
            // Core exercises
            "Planks",
            "Hanging Leg Raise",
            "Crunches",
            "Russian Twists",
            "Cable Woodchoppers",
            "Ab Wheel Rollout",
            "Bicycle Crunches",
            "Sit-Ups",
            "Cable Crunches",
            "Mountain Climbers",
            "Dead Bug",
            "V-Sit Hold",
            
            // Forearm exercises
            "Wrist Curls",
            "Reverse Wrist Curls",
            "Farmer's Walk",
            "Plate Pinches",
            "Zottman Curl",
            
            // Full body exercises
            "Clean and Jerk",
            "Snatch",
            "Kettlebell Swings",
            "Turkish Get-Up",
            "Thrusters",
            
            // Compound movements
            "Barbell Squat",
            "Deadlift",
            "Bench Press",
            "Pull-Ups",
            "Overhead Press",
            "Bent-Over Row"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // TextField to add new exercise with an autocomplete overlay
                VStack {
                    HStack {
                        TextField("New Exercise", text: $newExerciseName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .onChange(of: newExerciseName) { newValue in
                                updateSuggestions()
                            }
                            .onTapGesture {
                                showSuggestions = true
                            }

                        Button(action: {
                            addExercise()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 24))
                        }
                        .padding(.trailing)
                    }
                    .padding(.top)

                    // Autocomplete suggestion list that appears directly under the text field
                    if showSuggestions && !suggestedExercises.isEmpty {
                        List {
                            ForEach(suggestedExercises, id: \.self) { suggestion in
                                Button(action: {
                                    newExerciseName = suggestion
                                    addExercise()
                                }) {
                                    HStack {
                                        Text(suggestion)
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)  // Make the button span the entire width
                                    .contentShape(Rectangle())  // Ensure the entire row is clickable
                                }
                                .buttonStyle(PlainButtonStyle())  // Full row clickable
                            }
                        }
                        //.frame(maxHeight: 350)  // Limit height of suggestion list
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                }
                
                // List of added exercises
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
            .alert(isPresented: $showDuplicateAlert) {  // Alert for duplicate exercise
                Alert(
                    title: Text("Duplicate Exercise"),
                    message: Text("This exercise already exists."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func addExercise() {
        // Ensure no empty or duplicate exercise names are added
        guard !newExerciseName.isEmpty else { return }

        // Check for duplicates
        if exercises.contains(where: { $0.name.lowercased() == newExerciseName.lowercased() }) {
            // Show alert for duplicate entry
            showDuplicateAlert = true
        } else {
            let newExercise = Exercise(name: newExerciseName)
            exercises.append(newExercise)
            modelContext.insert(newExercise)
            saveContext()
            newExerciseName = ""  // Clear the text field after adding
            showSuggestions = false  // Hide suggestions after adding
        }
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

        let historyFetchRequest = FetchDescriptor<ExerciseHistory>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            let allHistories = try modelContext.fetch(historyFetchRequest)
            let historiesToDelete = allHistories.filter { $0.exerciseName == exercise.name }
            
            for history in historiesToDelete {
                modelContext.delete(history)
            }
            
            modelContext.delete(exercise)
            exercises.remove(at: index)
            saveContext()

            self.exercises = Array(exercises)
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
    
    // Update suggestions based on user input (Only after 3 characters entered)
    private func updateSuggestions() {
        if newExerciseName.count < 3 {
            suggestedExercises = []  // Clear suggestions if fewer than 3 characters
            showSuggestions = false
        } else {
            suggestedExercises = allPossibleExercises.filter {
                $0.lowercased().contains(newExerciseName.lowercased())
            }
            showSuggestions = true
        }
    }
}
