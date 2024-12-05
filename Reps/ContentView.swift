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
    @State private var exercises: [Exercise]?
    @State private var showingManageExercises = false
    @State private var refreshTrigger = false
    @State private var showingLogbook = false
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    @State private var startingHueIndex: Int = 0
    @StateObject private var themeManager = ThemeManager()
    
    private let exerciseColors: [Color] = [
        Color(hex: "#9B5DE5"),  // Purple p
        Color(hex: "#00CED1"),  // Dark Turquoise b
        Color(hex: "#32CD32"),  // Lime Green g
        Color(hex: "#FF4500"),  // Orange Red r
        Color(hex: "#FF1493"),  // Deep Pink p
        Color(hex: "#4169E1"),  // Royal Blue b
        Color(hex: "#00FA9A"),  // Medium Spring Green g
        Color(hex: "#DC143C"),  // Crimson r
        Color(hex: "#D83F87"),  // Pink Purple p
        Color(hex: "#8A2BE2"),  // Blue Violet b
        Color(hex: "#2E8B57"),  // Sea Green g
        Color(hex: "#FF8C00"),  // Dark Orange r
        Color(hex: "#BA55D3"),  // Medium Orchid p
        Color(hex: "#1E90FF"),  // Dodger Blue b
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                if exercises == nil {
                    // Loading state
                    LoadingView()
                        .transition(.opacity)
                } else if exercises?.isEmpty == true {
                    // Empty state
                    VStack {
                        Text("Start adding exercises!")
                            .font(.headline)
                            .foregroundColor(themeManager.textColor)
                            .padding()
                    }
                } else if let currentExercises = exercises {
                    // Exercise pager when exercises are available
                    VerticalPager(pageCount: currentExercises.count, currentIndex: $currentIndex) { index in
                        ExerciseView(
                            exercise: Binding(
                                get: { currentExercises[index] },
                                set: { newValue in
                                    var updatedExercises = currentExercises
                                    updatedExercises[index] = newValue
                                    exercises = updatedExercises
                                }
                            ),
                            refreshTrigger: $refreshTrigger,
                            weightWheelConfig: weightWheelConfig,
                            repWheelConfig: repWheelConfig,
                            RPEWheelConfig: exertionWheelConfig,
                            color: .clear,
                            userId: userId
                        )
                        .gradientBackground(color: exerciseColors[index % exerciseColors.count])
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: exercises)  // Animate state changes
            .onAppear {
                loadExercises()
            }
            .onChange(of: showingLogbook) { oldValue, newValue in
                if !newValue {
                    refreshTrigger.toggle()
                }
            }
            .onChange(of: refreshTrigger) { oldValue, newValue in
                loadExercises()
            }
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        impactFeedback.impactOccurred()
                        showingLogbook.toggle()
                    }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(themeManager.navigationIconColor)
                            .scaleEffect(x: 1.1, y: 1.1)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        impactFeedback.impactOccurred()
                        currentIndex = 0
                        showingManageExercises.toggle()
                    }) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.title2)
                            .foregroundColor(themeManager.navigationIconColor)
                            .scaleEffect(x: 0.9, y: 1)
                    }
                }
            }
        }
        .environmentObject(themeManager)
        .sheet(isPresented: $showingLogbook) {
            LogbookView(setCount: $setCount, refreshTrigger: $refreshTrigger)
                .environment(\.modelContext, modelContext)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingManageExercises) {
            ManageExercisesView(refreshTrigger: $refreshTrigger, exercises: Binding(
                get: { exercises ?? [] },
                set: { exercises = $0 }
            ), currentIndex: $currentIndex)
                .id(refreshTrigger)
                .environment(\.modelContext, modelContext)
                .environmentObject(themeManager)
        }
    }
    
    private func loadExercises() {
        exercises = nil  // Show loading state
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
                DispatchQueue.main.async {
                    exercises = []  // Show empty state on error
                }
            }
        }
    }
}
