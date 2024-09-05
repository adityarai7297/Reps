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
                // Reset to the first exercise
                currentIndex = 0
                showingManageExercises.toggle()
            }) {
                Image(systemName: "plus")
                    .foregroundColor(exercises.isEmpty ? .white : .black)
            })
            .sheet(isPresented: $showingManageExercises) {
                ManageExercisesView(refreshTrigger: $refreshTrigger, exercises: $exercises)
                    .id(refreshTrigger) // This ensures the sheet content is reloaded when refreshTrigger changes
                    .environment(\.modelContext, modelContext) // Pass model context to the modal
            }
            .onAppear {
                loadExercises()
            }
        }
        .preferredColorScheme(.dark)
        
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
