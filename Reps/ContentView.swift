import SwiftUI
import SwiftData
import FirebaseFirestore

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var weightWheelConfig: WheelPicker.Config = .init(count: 100, steps: 10, spacing: 7, multiplier: 5)
    @State private var repWheelConfig: WheelPicker.Config = .init(count: 100, steps: 1, spacing: 50, multiplier: 1)
    @State private var exertionWheelConfig: WheelPicker.Config = .init(count: 10, steps: 1, spacing: 50, multiplier: 10)
    @State private var userId = "XXXXX"
    @State private var currentIndex: Int = 0
    @State private var exercises: [Exercise] = []
    @State private var showingManageExercises = false
    @State private var refreshTrigger = false

    var body: some View {
        NavigationView {
            ZStack {
                if exercises.isEmpty {
                    Text("No exercises available. Please add new exercises.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    VerticalPager(pageCount: exercises.count, currentIndex: $currentIndex) {
                        ForEach(exercises.indices, id: \.self) { index in
                            ExerciseView(
                                exercise: $exercises[index],
                                weightWheelConfig: weightWheelConfig,
                                repWheelConfig: repWheelConfig,
                                RPEWheelConfig: exertionWheelConfig,
                                color: .clear, // Set to clear since gradient will be applied
                                userId: userId
                            )
                            .gradientBackground(index: index)
                        }
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: {
                showingManageExercises.toggle()
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.black)
            })
            .sheet(isPresented: $showingManageExercises) {
                ManageExercisesView(refreshTrigger: $refreshTrigger, exercises: $exercises)
                    .id(refreshTrigger)
                    .environment(\.modelContext, modelContext) // Pass model context to the modal
            }
            .onAppear {
                loadExercises()
            }
        }
    }

    private func loadExercises() {
        let fetchRequest = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)] // Fetch exercises in their saved order
        )

        do {
            exercises = try modelContext.fetch(fetchRequest)
        } catch {
            print("Failed to load exercises: \(error)")
        }
    }
}
