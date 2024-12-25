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
    @AppStorage("hasShownSwipeHint") private var hasShownSwipeHint = false
    @State private var showSwipeHint = false
    @State private var isAnimatingIcon = false
    
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
                                    self.exercises = updatedExercises
                                }
                            ),
                            refreshTrigger: $refreshTrigger,
                            weightWheelConfig: weightWheelConfig,
                            repWheelConfig: repWheelConfig,
                            RPEWheelConfig: exertionWheelConfig,
                            color: .clear,
                            userId: userId
                        )
                        .background(
                            GradientPair.animatedGradient(GradientTheme.gradientAt(index: index))
                                .transition(.opacity)
                        )
                    }
                    .blur(radius: showSwipeHint ? 10 : 0)
                    .animation(.easeInOut(duration: 0.3), value: showSwipeHint)
                    .overlay(
                        Group {
                            if showSwipeHint {
                                Color.black.opacity(0.3)
                                    .ignoresSafeArea()
                                    .transition(.opacity)
                                VStack {
                                    Image(systemName: "hand.draw.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 8)
                                        .offset(y: isAnimatingIcon ? -10 : 10)
                                        .animation(
                                            Animation.easeInOut(duration: 1)
                                                .repeatForever(autoreverses: true),
                                            value: isAnimatingIcon
                                        )
                                        .onAppear {
                                            isAnimatingIcon = true
                                        }
                                    Text("Swipe up or down\nto change exercise")
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                                .padding(20)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(15)
                                .transition(.opacity)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            showSwipeHint = false
                                            hasShownSwipeHint = true
                                            print("DEBUG: Swipe hint dismissed, hasShownSwipeHint set to true")
                                        }
                                    }
                                }
                            }
                        }
                    )
                }
            }
            .animation(.easeInOut(duration: 0.2), value: exercises)
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
            .onChange(of: showingManageExercises) { oldValue, newValue in
                if !newValue {  // When returning from ManageExercisesView
                    loadExercises()
                }
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
                .onAppear {
                    print("DEBUG: ManageExercisesView sheet appeared")
                }
                .onDisappear {
                    print("DEBUG: ManageExercisesView sheet disappeared")
                }
        }
    }
    
    private func loadExercises() {
        let fetchRequest = FetchDescriptor<Exercise>()
        do {
            let loadedExercises = try modelContext.fetch(fetchRequest)
            exercises = loadedExercises
            
            print("DEBUG: hasShownSwipeHint = \(hasShownSwipeHint)")
            print("DEBUG: loadedExercises.count = \(loadedExercises.count)")
            
            if !hasShownSwipeHint && loadedExercises.count >= 2 {
                print("DEBUG: Should show swipe hint")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        showSwipeHint = true
                        print("DEBUG: Setting showSwipeHint to true")
                    }
                }
            } else {
                print("DEBUG: Swipe hint conditions not met: hasShownSwipeHint=\(hasShownSwipeHint), exercises=\(loadedExercises.count)")
            }
        } catch {
            print("Failed to load exercises: \(error)")
        }
    }
}
