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
    @State private var catOffset: CGFloat = UIScreen.main.bounds.height // Start off-screen

    var body: some View {
        NavigationView {
            ZStack {
                if exercises.isEmpty {
                    VStack {
                        Text("Start adding exercises!")
                            .font(.headline)
                            .padding()
                        Image("CatWorkingOut")
                            .resizable()
                            .frame(width: 300, height: 220) // Adjust size as needed
                    }
                } else {
                    VerticalPager(pageCount: exercises.count, currentIndex: $currentIndex) { index in
                        ExerciseView(
                            exercise: $exercises[index],
                            refreshTrigger: $refreshTrigger, weightWheelConfig: weightWheelConfig,
                            repWheelConfig: repWheelConfig,
                            RPEWheelConfig: exertionWheelConfig,
                            color: .clear, // Since gradient is applied
                            userId: userId // Pass the binding here
                        )
                        .gradientBackground(index: index)
                    }
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    showingLogbook.toggle()
                }) {
                    Image(systemName: "book.pages")
                        .font(.title2)
                        .foregroundColor(exercises.isEmpty ? .white : .black)
                },
                trailing: Button(action: {
                    // Reset to the first exercise
                    currentIndex = 0
                    showingManageExercises.toggle()
                }) {
                    Image(systemName: "list.bullet")
                        .foregroundColor(exercises.isEmpty ? .white : .black)
                }
            )
            .sheet(isPresented: $showingLogbook) {
                LogbookView(setCount: $setCount, refreshTrigger: $refreshTrigger) // Pass refreshTrigger
                    .environment(\.modelContext, modelContext)
            }
            .sheet(isPresented: $showingManageExercises) {
                ManageExercisesView(refreshTrigger: $refreshTrigger, exercises: $exercises, currentIndex: $currentIndex)
                    .id(refreshTrigger) // This ensures the sheet content is reloaded when refreshTrigger changes
                    .environment(\.modelContext, modelContext) // Pass model context to the modal
            }
            .onAppear {
                loadExercises()
            }
            // Trigger refresh when LogbookView is dismissed
            .onChange(of: showingLogbook) { newValue in
                if !newValue {
                    refreshTrigger.toggle()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // The loadExercises function that fetches exercises from the model context
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
