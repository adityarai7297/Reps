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

    // For animation
    @State private var showOptions = false

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

                // Radial button and options
                radialMenu
                    .foregroundColor(exercises.isEmpty ? .white : .black) // Set the color conditionally
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

    // MARK: - Radial Menu
    private var radialMenu: some View {
        ZStack {
            // Background blur when options are showing
            if showOptions {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showOptions.toggle()
                        }
                    }
            }

            // Central button (smaller, in the bottom-left corner, black color)
            Button(action: {
                // Haptic feedback on central button tap
                impactFeedback.impactOccurred()
                withAnimation(.spring()) {
                    showOptions.toggle()
                }
            }) {
                Image(systemName: "arrow.down.left.topright.rectangle")
                    .font(.system(size: 30))  // Smaller size
                    .fontWeight(.light)
            }
            // Bottom-left corner position with a slight vertical offset (20 points from the bottom)
            .position(x: UIScreen.main.bounds.width*0.9, y: UIScreen.main.bounds.height*0.02)

            // Logbook button (pops out when central button is tapped)
            if showOptions {
                Button(action: {
                    // Haptic feedback on Logbook button tap
                    impactFeedback.impactOccurred()
                    showingLogbook.toggle()
                    showOptions = false // Close options after selection
                }) {
                    Image(systemName: "book.pages")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.blue))
                }
                .offset(x: -60, y: 0) // Position it radially (above-left)
                .transition(.scale)
            }

            // Manage Exercises button (pops out when central button is tapped)
            if showOptions {
                Button(action: {
                    // Haptic feedback on Manage Exercises button tap
                    impactFeedback.impactOccurred()
                    currentIndex = 0
                    showingManageExercises.toggle()
                    showOptions = false // Close options after selection
                }) {
                    Image(systemName: "list.bullet")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.green))
                }
                .offset(x: 60, y: 0) // Position it radially (above-right)
                .transition(.scale)
            }
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
