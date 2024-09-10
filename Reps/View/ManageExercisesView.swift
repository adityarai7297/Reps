import SwiftUI
import SwiftData

struct ManageExercisesView: View {
    @Environment(\.dismiss) private var dismiss // To dismiss the modal
    @Environment(\.modelContext) private var modelContext
    @Binding var refreshTrigger: Bool
    @Binding var exercises: [Exercise]
    @Binding var currentIndex: Int // Binding to update the vertical pager
    @State private var newExerciseName: String = ""
    @State private var editingExercise: Exercise?
    @State private var showSuggestions: Bool = false
    @State private var suggestedExercises: [String] = []
    @State private var showDuplicateAlert: Bool = false  // State for showing duplicate alert
    @State private var showingEditSheet = false          // State for showing the edit sheet
    @State private var editedExerciseName: String = ""   // State for holding the edited name

    let allPossibleExercises = [
        // Chest exercises
        "Bench Press",
        "Incline Bench Press",
        "Decline Bench Press",
        "Chest Flyes",
        "Cable Crossovers",
        "Push-Ups",
        "Dumbbell Bench Press",
        "Dumbbell Flyes",
        "Pec Deck Machine",
        "Guillotine Press",
        "Hex Press",
        "Svend Press",
        "Cable Chest Press",
        "Machine Chest Press",
        "Smith Machine Bench Press",
        "Landmine Press",
        "Dumbbell Pullover",  // Added pullover
        "Machine Pullover",   // Added pullover
        "Cable Pullover",     // Added pullover

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
        "Inverted Row",
        "Seal Row",
        "Pendlay Row",
        "Kroc Row",
        "Machine Row",
        "Single Arm Cable Row",
        "Wide Grip Pull-Up",
        "Meadows Row",
        "Chest Supported Row",
        "Neutral Grip Pull-Up",
        "Trap Bar Deadlift",
        "Deficit Deadlift",
        "Stiff-Legged Deadlift",
        "Snatch-Grip Deadlift",
        "Good Mornings",
        "Dumbbell Pullover (for back emphasis)",  // Added back emphasis pullover

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
        "Landmine Shoulder Press",
        "Smith Machine Overhead Press",
        "Cuban Press",
        "Snatch-Grip Overhead Press",
        "Z-Press",
        "Standing Dumbbell Press",
        "Machine Shoulder Press",
        "Cable Front Raise",
        "Y Raises",
        "Behind-the-Neck Press",
        "Scaption",

        // Bicep exercises
        "Barbell Bicep Curl",
        "Dumbbell Bicep Curl",
        "Preacher Curl",
        "Hammer Curl",
        "Concentration Curl",
        "Cable Curl",
        "Incline Dumbbell Curl",
        "Spider Curl",
        "Cable Preacher Curl",
        "Drag Curl",
        "Bayesian Curl",
        "21s Bicep Curl",
        "EZ Bar Curl",
        "Cable Hammer Curl",
        "Reverse Curl",
        "Concentration Cable Curl",
        "Incline Hammer Curl",

        // Tricep exercises
        "Tricep Dips",
        "Skull Crushers",
        "Close-Grip Bench Press",
        "Tricep Pushdowns",
        "Overhead Tricep Extension",
        "Dumbbell Kickbacks",
        "Cable Tricep Extension",
        "Dumbbell Floor Press",
        "Diamond Push-Ups",
        "Rope Pushdowns",
        "Single Arm Tricep Pushdown",
        "Reverse Grip Tricep Pushdown",
        "Smith Machine Close Grip Bench",
        "Cable Kickback",
        "Tricep Extensions on Bench",
        "JM Press",
        "Ring Dips",

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
        "Smith Machine Squat",
        "Anderson Squats",
        "Jefferson Squat",
        "Sissy Squat",
        "Belt Squat",
        "Overhead Squat",
        "Kang Squat",
        "Box Squat",
        "Pistol Squats",
        "Sled Push",
        "Sled Pull",
        "Nordic Curls",
        "Reverse Hack Squat",
        "Barbell Hip Thrust",
        "Cable Pull-Through",
        "Landmine Squat",
        "Smith Machine Lunges",
        "Cossack Squat",
        "Single-Leg Press",
        "Lateral Lunges",

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
        "Dragon Flag",
        "Weighted Planks",
        "Stir-the-Pot",
        "L-Sit",
        "Hollow Body Hold",
        "Garhammer Raise",
        "Cable Pallof Press",
        "Flutter Kicks",
        "Toe-to-Bar",
        "Oblique Crunches",
        "Cable Side Bends",
        "Side Plank",
        "Jackknives",

        // Forearm exercises
        "Wrist Curls",
        "Reverse Wrist Curls",
        "Farmer's Walk",
        "Plate Pinches",
        "Zottman Curl",
        "Reverse Curl with EZ Bar",
        "Behind-the-Back Wrist Curls",
        "Towel Grip Pull-Ups",
        "Fat Grip Bar Holds",
        "Finger Curls",
        "Wrist Roller",
        "Thick Bar Deadlifts",

        // Full body exercises
        "Clean and Jerk",
        "Snatch",
        "Kettlebell Swings",
        "Turkish Get-Up",
        "Thrusters",
        "Overhead Squat",
        "Dumbbell Snatch",
        "Kettlebell Clean",
        "Squat Clean",
        "Kettlebell High Pull",
        "Man Makers",
        "Barbell Complexes",
        "Dumbbell Thruster",
        "Devil Press",
        "Kettlebell Turkish Get-Up",
        "Clean Pull",

        // Compound movements
        "Barbell Squat",
        "Deadlift",
        "Bench Press",
        "Pull-Ups",
        "Overhead Press",
        "Bent-Over Row",
        "Log Press",
        "Tire Flip",
        "Stone to Shoulder",
        "Farmers Walk with Trap Bar",
        "Zercher Squat",
        "Sots Press",

        // Isolation and machine-based movements
        "Leg Adduction",
        "Leg Abduction",
        "Machine Hamstring Curl",
        "Cable Glute Kickbacks",
        "Machine Hip Abduction",
        "Smith Machine Calf Raise",
        "Leg Extension Machine",
        "Standing Hamstring Curl",
        "Single Leg Curl Machine",

        // Olympic Lifting Variations
        "Power Clean",
        "Power Snatch",
        "Hang Clean",
        "Hang Snatch",
        "Split Jerk",
        "Push Jerk",
        "Push Press",
        "Snatch Balance",
        "Hang Power Clean",

        // Unique Variations
        "Paused Deadlift",
        "Banded Bench Press",
        "Banded Squats",
        "Deficit Bulgarian Split Squat",
        "Single Leg Romanian Deadlift",
        "Safety Bar Squat",
        "Zercher Deadlift",
        "Cluster Set Deadlifts",
        "Eccentric Pull-Ups",
        "Paused Squats",
        "Tempo Bench Press"
    ];

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
                                    .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                }

                // List of added exercises with swipe to delete and edit, and tap to move pager
                List {
                    ForEach(exercises.indices, id: \.self) { index in
                        HStack {
                            Text(exercises[index].name)
                                .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle()) // Make the entire row tappable
                        .onTapGesture {
                            currentIndex = index  // Move the vertical pager to the tapped exercise
                            dismiss()             // Dismiss the modal view
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button("Edit") {
                                startEditing(exercise: exercises[index])
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete") {
                                deleteExercise(exercises[index])
                            }
                            .tint(.red)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Manage Exercises")
            .alert(isPresented: $showDuplicateAlert) {
                Alert(
                    title: Text("Duplicate Exercise"),
                    message: Text("This exercise already exists."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showingEditSheet) {
                VStack {
                    TextField("Exercise Name", text: $editedExerciseName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Save") {
                        if let exercise = editingExercise {
                            saveChanges(for: exercise)
                        }
                        showingEditSheet = false
                    }
                    .padding()

                    Button("Cancel") {
                        showingEditSheet = false
                    }
                    .padding()
                }
                .presentationDetents([.fraction(0.3)]) // Set the sheet size
            }
        }
    }

    // Helper function to start editing an exercise
    private func startEditing(exercise: Exercise) {
        editingExercise = exercise
        editedExerciseName = exercise.name
        showingEditSheet = true
    }

    private func addExercise() {
        // Ensure no empty or duplicate exercise names are added
        guard !newExerciseName.isEmpty else { return }

        // Check for duplicates
        if exercises.contains(where: { $0.name.lowercased() == newExerciseName.lowercased() }) {
            showDuplicateAlert = true
        } else {
            let newExercise = Exercise(name: newExerciseName)
            exercises.append(newExercise)
            modelContext.insert(newExercise)
            saveContext()
            newExerciseName = ""  // Clear the text field after adding
            showSuggestions = false
        }
    }

    private func saveChanges(for exercise: Exercise) {
        // Ensure the new name isn't empty and the exercise is valid
        guard !editedExerciseName.isEmpty, let index = exercises.firstIndex(of: exercise) else { return }

        let oldName = exercise.name // Store the old exercise name
        exercises[index].name = editedExerciseName // Update the exercise name

        // Update the exercise history records with the new exercise name
        let historyFetchRequest = FetchDescriptor<ExerciseHistory>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let allHistories = try modelContext.fetch(historyFetchRequest)
            let historiesToUpdate = allHistories.filter { $0.exerciseName == oldName }

            // Update each history record with the new exercise name
            for history in historiesToUpdate {
                history.exerciseName = editedExerciseName
            }

            // Save the changes in the context
            saveContext()
        } catch {
            print("Failed to update exercise history: \(error)")
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
