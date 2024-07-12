import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @State private var weightWheelConfig: WheelPicker.Config = .init(count: 100, steps: 10, spacing: 7, multiplier: 5)
    @State private var repWheelConfig: WheelPicker.Config = .init(count: 100, steps: 1, spacing: 50, multiplier: 1)
    @State private var exertionWheelConfig: WheelPicker.Config = .init(count: 10, steps: 1, spacing: 50, multiplier: 10)
    
    @State private var exerciseStates: [ExerciseState] = []
    @State private var currentIndex: Int = 0
    @State private var showExerciseListView: Bool = false
    @State private var isLoading: Bool = true
    @State private var arrowOffset: CGFloat = -60
    let userId: String = "your_user_id"

    var body: some View {
        ZStack {
            if isLoading {
                Text("Loading...")
                    .onAppear {
                        loadExercisesFromFirebase()
                    }
            } else if exerciseStates.isEmpty {
                EmptyStateView()
            } else {
                VerticalPager(pageCount: exerciseStates.count, currentIndex: $currentIndex) {
                    ForEach(exerciseStates.indices, id: \.self) { index in
                        ExerciseView(
                            state: $exerciseStates[index],
                            exerciseName: $exerciseStates[index].exerciseName,
                            weightWheelConfig: weightWheelConfig,
                            repWheelConfig: repWheelConfig,
                            RPEWheelConfig: exertionWheelConfig,
                            color: .clear, // Set to clear since gradient will be applied
                            userId: userId
                        )
                        .gradientBackground(index: index)
                        .onAppear {
                            loadCurrentState(for: exerciseStates[index].exerciseName, at: index)
                        }
                    }
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showExerciseListView = true
                    }) {
                        Image(systemName: "rectangle.stack")
                            .resizable()
                            .frame(width: 25, height: 35)
                            .foregroundColor(Color.black)
                    }
                    .padding()
                    .overlay(
                        VStack {
                            if exerciseStates.isEmpty {
                                HStack {
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .frame(width: 40, height: 25)
                                        .foregroundColor(.gray)
                                        .offset(x: arrowOffset)
                                        .onAppear {
                                            startBouncingArrow()
                                        }
                                }
                            }
                        }
                    )
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showExerciseListView) {
            ExerciseListView(exerciseStates: $exerciseStates, currentIndex: $currentIndex, userId: userId)
        }
    }

    func loadExercisesFromFirebase() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.collection("exercises").getDocuments { snapshot, error in
            if let error = error {
                print("Error loading exercises: \(error)")
            } else {
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                self.exerciseStates = documents.map { doc in
                    ExerciseState(
                        exerciseName: doc["exerciseName"] as? String ?? "",
                        lastWeightValue: 0,
                        lastRepValue: 0,
                        lastRPEValue: 0,
                        setCount: 0,
                        showCheckmark: false
                    )
                }
                print("Loaded exercises: \(self.exerciseStates)")
                self.isLoading = false
                // Ensure currentIndex is within bounds
                if currentIndex >= exerciseStates.count {
                    currentIndex = max(0, exerciseStates.count - 1)
                }
            }
        }
    }

    func loadCurrentState(for exerciseName: String, at index: Int) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        userRef.collection("exercises").document(exerciseName).getDocument { document, error in
            if let error = error {
                print("Error loading current state: \(error)")
            } else if let document = document, document.exists {
                if let data = document.data(), let lastState = data["lastState"] as? [String: Any] {
                    DispatchQueue.main.async {
                        exerciseStates[index].lastWeightValue = lastState["weight"] as? Double ?? 0
                        exerciseStates[index].lastRepValue = lastState["reps"] as? Double ?? 0
                        exerciseStates[index].lastRPEValue = lastState["RPE"] as? Double ?? 0
                        exerciseStates[index].setCount = lastState["dailySetCount"] as? Int ?? 0
                    }
                } else {
                    print("No lastState data found")
                }
            }
        }
    }

    func startBouncingArrow() {
        arrowOffset = -60
        withAnimation(Animation.interpolatingSpring(stiffness: 20, damping: 0).repeatForever(autoreverses: true)) {
            arrowOffset = -50
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
