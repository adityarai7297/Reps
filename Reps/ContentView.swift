import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var weightWheelConfig: WheelPicker.Config = .init(count: 100, steps: 10, spacing: 7, multiplier: 5)
    @State private var repWheelConfig: WheelPicker.Config = .init(count: 100, steps: 1, spacing: 50, multiplier: 1)
    @State private var exertionWheelConfig: WheelPicker.Config = .init(count: 10, steps: 1, spacing: 50, multiplier: 10)
    @State private var userId = "XXXXX"
    @State private var currentIndex: Int = 0
    @State private var setCount: Int = 0
    @State private var exercises: [Exercise] = []
    @State private var showingManageExercises = false
    @State private var refreshTrigger = false // Used to trigger refresh
    @State private var showingLogbook = false
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .medium) // Haptic Feedback

    var body: some View {
        NavigationView {
            ZStack {
                if exercises.isEmpty {
                    // No exercises UI
                    VStack {
                        Text("Start adding exercises!")
                            .font(.headline)
                            .padding()
                        Image("CatWorkingOut")
                            .resizable()
                            .frame(width: 300, height: 220) // Adjust size as needed
                    }
                } else {
                    // Exercise pager when exercises are available
                    VerticalPager(pageCount: exercises.count, currentIndex: $currentIndex) { index in
                        ExerciseView(
                            exercise: $exercises[index],
                            refreshTrigger: $refreshTrigger,
                            weightWheelConfig: weightWheelConfig,
                            repWheelConfig: repWheelConfig,
                            RPEWheelConfig: exertionWheelConfig,
                            color: .clear, // Since gradient is applied
                            userId: userId // Pass the binding here
                        )
                        .gradientBackground(index: index)
                    }
                }
            }
            .onAppear {
                loadExercises()
            }
            .onChange(of: showingLogbook) { oldValue, newValue in
                if !newValue {
                    refreshTrigger.toggle()
                }
            }
            .preferredColorScheme(.dark)
            .toolbar {
                // Logbook button on top left
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        impactFeedback.impactOccurred()
                        showingLogbook.toggle()
                    }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }

                // Manage Exercises button on top right
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        impactFeedback.impactOccurred()
                        currentIndex = 0
                        showingManageExercises.toggle()
                    }) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.title2)
                            .foregroundColor(exercises.isEmpty ? .white : .black)
                            .scaleEffect(x: 0.9, y: 1)
                            
                    }
                }
            }
        }
        // Logbook sheet presentation
        .sheet(isPresented: $showingLogbook) {
            LogbookView(setCount: $setCount, refreshTrigger: $refreshTrigger)
                .environment(\.modelContext, modelContext)
        }
        // Manage exercises sheet presentation
        .sheet(isPresented: $showingManageExercises) {
            ManageExercisesView(refreshTrigger: $refreshTrigger, exercises: $exercises, currentIndex: $currentIndex)
                .id(refreshTrigger) // Reload the sheet when refreshTrigger changes
                .environment(\.modelContext, modelContext)
        }
    }

    // Load exercises from model context
    private func loadExercises() {
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchRequest = FetchDescriptor<Exercise>(
                sortBy: [SortDescriptor(\.name)]
            )
            do {
                let fetchedExercises = try modelContext.fetch(fetchRequest)
                DispatchQueue.main.async {
                    exercises = fetchedExercises
                }
            } catch {
                print("Failed to load exercises: \(error)")
            }
        }
    }
}
