import SwiftUI
import SwiftData
import UIKit

struct TextInputPreloader: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            let textField = UITextField()
            view.addSubview(textField)
            textField.becomeFirstResponder()
            DispatchQueue.main.async {
                textField.resignFirstResponder()
                textField.removeFromSuperview()
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ManageExercisesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var refreshTrigger: Bool
    @Binding var exercises: [Exercise]
    @Binding var currentIndex: Int
    @State private var newExerciseName: String = ""
    @State private var editingExercise: Exercise?
    @State private var showSuggestions: Bool = false
    @State private var suggestedExercises: [String] = []
    @State private var showDuplicateAlert: Bool = false
    @State private var showingEditSheet = false
    @State private var editedExerciseName: String = ""
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    @FocusState private var isTextFieldFocused: Bool {
        didSet {
            print("DEBUG: FocusState didSet called with value: \(isTextFieldFocused)")
        }
    }
    @State private var isViewReady: Bool = false
    @State private var showFocusRing: Bool = false

    let allPossibleExercises = ExerciseData.allExercises

    init(refreshTrigger: Binding<Bool>, exercises: Binding<[Exercise]>, currentIndex: Binding<Int>) {
        print("DEBUG: ManageExercisesView initialized")
        self._refreshTrigger = refreshTrigger
        self._exercises = exercises
        self._currentIndex = currentIndex
    }

    var body: some View {
        let _ = print("DEBUG: Body evaluation started")
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Manage Exercises")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .onAppear {
                print("DEBUG: ManageExercisesView - onAppear")
            }
            
            // Hidden preloader
            TextInputPreloader()
                .frame(width: 0, height: 0)

            // Add Exercise Section
            VStack(spacing: 16) {
                HStack {
                    TextField("Add new exercise", text: $newExerciseName)
                        .focused($isTextFieldFocused)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isTextFieldFocused ? Color.yellow : Color.clear, lineWidth: 2)
                                )
                        )
                        .foregroundColor(.white)
                        .onChange(of: newExerciseName) { _, _ in
                            print("DEBUG: TextField value changed to: \(newExerciseName)")
                            updateSuggestions()
                        }
                        .onChange(of: isTextFieldFocused) { oldValue, newValue in
                            let timestamp = Date().timeIntervalSince1970
                            print("DEBUG: [\(timestamp)] TextField focus changed from: \(oldValue) to: \(newValue)")
                            if newValue {
                                impactFeedback.prepare()
                                impactFeedback.impactOccurred(intensity: 0.7)
                            }
                        }
                        .onAppear {
                            print("DEBUG: TextField - onAppear")
                            // Initialize keyboard system
                            UITextField.appearance().tintColor = .yellow
                        }
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                    Button(action: addExercise) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 24))
                    }
                    .disabled(newExerciseName.isEmpty)
                }
                .padding(.horizontal, 20)

                // Suggestions
                if showSuggestions && !suggestedExercises.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestedExercises, id: \.self) { suggestion in
                                Button(action: {
                                    newExerciseName = suggestion
                                    showSuggestions = false
                                    impactFeedback.impactOccurred()
                                    addExercise()
                                }) {
                                    Text(suggestion)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.yellow.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 20)

            // Exercise List
            List {
                ForEach(exercises.indices, id: \.self) { index in
                    ExerciseRow(
                        exercise: exercises[index],
                        onTap: {
                            impactFeedback.impactOccurred()
                            currentIndex = index
                            dismiss()
                        },
                        onEdit: {
                            startEditing(exercise: exercises[index])
                        },
                        onDelete: {
                            deleteExercise(exercises[index])
                        }
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                }
                .onMove(perform: moveExercise)
            }
            .listStyle(PlainListStyle())
            .background(Color.black)
        }
        .background(Color.black)
        .alert(isPresented: $showDuplicateAlert) {
            Alert(
                title: Text("Duplicate Exercise"),
                message: Text("This exercise already exists."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditExerciseSheet(
                exerciseName: $editedExerciseName,
                onSave: {
                    if let exercise = editingExercise {
                        saveChanges(for: exercise)
                    }
                    showingEditSheet = false
                },
                onCancel: {
                    showingEditSheet = false
                }
            )
        }
    }

    // MARK: - Helper Functions

    private func startEditing(exercise: Exercise) {
        editingExercise = exercise
        editedExerciseName = exercise.name
        showingEditSheet = true
    }

    private func addExercise() {
        impactFeedback.impactOccurred(intensity: 0.7)
        guard !newExerciseName.isEmpty else { return }

        if exercises.contains(where: { $0.name.caseInsensitiveCompare(newExerciseName) == .orderedSame }) {
            showDuplicateAlert = true
        } else {
            let newExercise = Exercise(name: newExerciseName)
            exercises.append(newExercise)
            modelContext.insert(newExercise)
            saveContext()
            newExerciseName = ""
            showSuggestions = false
        }
    }

    private func saveChanges(for exercise: Exercise) {
        guard !editedExerciseName.isEmpty, let index = exercises.firstIndex(of: exercise) else { return }

        let oldName = exercise.name
        exercises[index].name = editedExerciseName

        let historyFetchRequest = FetchDescriptor<ExerciseHistory>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let allHistories = try modelContext.fetch(historyFetchRequest)
            let historiesToUpdate = allHistories.filter { $0.exerciseName == oldName }

            for history in historiesToUpdate {
                history.exerciseName = editedExerciseName
            }

            saveContext()
        } catch {
            print("Failed to update exercise history: \(error)")
        }
    }

    private func deleteExercise(_ exercise: Exercise?) {
        guard let exercise = exercise,
              let index = exercises.firstIndex(of: exercise) else {
            return
        }

        if exercises.count == 1 {
            currentIndex = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                exercises.remove(at: index)
                dismiss()
            }
        } else {
            exercises.remove(at: index)
            if currentIndex >= exercises.count {
                currentIndex = exercises.count - 1
            }
            refreshTrigger.toggle()
        }

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

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    private func updateSuggestions() {
        let startTime = CFAbsoluteTimeGetCurrent()
        guard newExerciseName.count >= 2 else {
            suggestedExercises = []
            showSuggestions = false
            print("DEBUG: Suggestions cleared - took \((CFAbsoluteTimeGetCurrent() - startTime) * 1000)ms")
            return
        }

        let filteredExercises = allPossibleExercises.filter {
            $0.localizedCaseInsensitiveContains(newExerciseName)
        }

        suggestedExercises = Array(filteredExercises.prefix(5))
        showSuggestions = !suggestedExercises.isEmpty
        print("DEBUG: Suggestions updated - took \((CFAbsoluteTimeGetCurrent() - startTime) * 1000)ms")
    }

    private func moveExercise(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
        
        // Just trigger refresh after moving
        refreshTrigger.toggle()
        
        // Save the new order
        do {
            try modelContext.save()
        } catch {
            print("Failed to save exercise order: \(error)")
        }
    }

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
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to calculate set count for \(exerciseName): \(error)")
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct ExerciseRow: View {
    let exercise: Exercise
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.gray)
                    .padding(.trailing, 8)
                
                Text(exercise.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
        }
    }
}

struct EditExerciseSheet: View {
    @Binding var exerciseName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Exercise")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            TextField("Exercise Name", text: $exerciseName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .foregroundColor(.gray)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Button(action: onSave) {
                    Text("Save")
                        .foregroundColor(.black)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.yellow)
                        .cornerRadius(8)
                }
            }
        }
        .padding(24)
        .background(Color.black)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
    }
}
