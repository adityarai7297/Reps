import SwiftUI
import SwiftData

struct ManageExercisesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var refreshTrigger: Bool
    @Binding var exercises: [Exercise]
    @Binding var currentIndex: Int // To update the pager view index
    @State private var newExerciseName: String = ""
    @State private var editingExercise: Exercise?
    @State private var showSuggestions: Bool = false
    @State private var suggestedExercises: [String] = []
    @State private var showDuplicateAlert: Bool = false
    @State private var showingEditSheet = false
    @State private var editedExerciseName: String = ""
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

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
                        "Dumbbell Pullover",
                        "Machine Pullover",
                        "Cable Pullover",

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
                        "Dumbbell Pullover (for back emphasis)",

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
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // TextField to add a new exercise
                HStack {
                    TextField("New Exercise", text: $newExerciseName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: newExerciseName) {
                            updateSuggestions()
                        }
                        .onTapGesture {
                            showSuggestions = true
                        }
                        .padding(.horizontal)

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

                // Suggestion list under TextField
                if showSuggestions && !suggestedExercises.isEmpty {
                    VStack {
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
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(height: min(200, CGFloat(suggestedExercises.count * 44)))
                        .cornerRadius(8)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                }

                // List of added exercises with reorder functionality
                List {
                    ForEach(exercises.indices, id: \.self) { index in
                        HStack {
                            Text(exercises[index].name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            impactFeedback.impactOccurred()
                            currentIndex = index
                            dismiss()
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
                        .gesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    impactFeedback.impactOccurred()
                                }
                        )
                    }
                    .onMove(perform: moveExercise)
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
                .presentationDetents([.fraction(0.3)])
            }
        }
    }

    // MARK: - Helper Functions

    // Start editing an exercise
    private func startEditing(exercise: Exercise) {
        editingExercise = exercise
        editedExerciseName = exercise.name
        showingEditSheet = true
    }

    // Add a new exercise
    private func addExercise() {
        guard !newExerciseName.isEmpty else { return }

        // Check for duplicates
        if exercises.contains(where: { $0.name.caseInsensitiveCompare(newExerciseName) == .orderedSame }) {
            showDuplicateAlert = true
        } else {
            let newExercise = Exercise(name: newExerciseName)
            exercises.append(newExercise)

            // Perform modelContext operations on the main thread
            modelContext.insert(newExercise)
            saveContext()

            newExerciseName = ""  // Clear the text field
            showSuggestions = false
        }
    }

    // Save changes to an exercise
    private func saveChanges(for exercise: Exercise) {
        guard !editedExerciseName.isEmpty, let index = exercises.firstIndex(of: exercise) else { return }

        let oldName = exercise.name
        exercises[index].name = editedExerciseName

        // Perform modelContext operations on the main thread
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

            saveContext()
        } catch {
            print("Failed to update exercise history: \(error)")
        }
    }

    // Delete an exercise
    private func deleteExercise(_ exercise: Exercise?) {
        guard let exercise = exercise,
              let index = exercises.firstIndex(of: exercise) else {
            return
        }

        exercises.remove(at: index)
        refreshTrigger.toggle()

        let exerciseNameToDelete = exercise.name

        let historyFetchRequest = FetchDescriptor<ExerciseHistory>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let allHistories = try modelContext.fetch(historyFetchRequest)
            let historiesToDelete = allHistories.filter { $0.exerciseName == exerciseNameToDelete }

            for history in historiesToDelete {
                modelContext.delete(history)
            }

            modelContext.delete(exercise)
            saveContext()
        } catch {
            print("Failed to delete exercise or exercise history: \(error)")
        }
    }

    // Save the Core Data context
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    // Update exercise suggestions based on the input
    private func updateSuggestions() {
        guard newExerciseName.count >= 2 else {
            suggestedExercises = []
            showSuggestions = false
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let suggestions = allPossibleExercises.filter {
                $0.lowercased().contains(newExerciseName.lowercased())
            }

            DispatchQueue.main.async {
                suggestedExercises = suggestions
                showSuggestions = !suggestions.isEmpty
            }
        }
    }

    // Move exercises and recalculate set count after reordering
    private func moveExercise(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
        
        // Recalculate set count for each moved exercise
        for index in source {
            let movedExercise = exercises[index]
            calculateSetCountForExercise(movedExercise)
        }
        
        // Trigger refresh
        refreshTrigger.toggle()
    }

    // Recalculate set count for a given exercise
    private func calculateSetCountForExercise(_ exercise: Exercise) {
        let exerciseName = exercise.name
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        DispatchQueue.global(qos: .userInitiated).async {
            let predicate = #Predicate<ExerciseHistory> { history in
                history.exerciseName == exerciseName &&
                history.timestamp >= startOfDay && history.timestamp < endOfDay
            }

            let fetchRequest = FetchDescriptor<ExerciseHistory>(
                predicate: predicate
            )

            do {
                let todayHistory = try modelContext.fetch(fetchRequest)

                DispatchQueue.main.async {
                    print("Set count for \(exerciseName): \(todayHistory.count)")
                    // Optionally update the UI or log the new set count
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to calculate set count for \(exerciseName): \(error)")
                }
            }
        }
    }
}
