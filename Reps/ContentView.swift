import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @State private var weightWheelConfig: WheelPicker.Config = .init(
        count: 100,
        steps: 10,
        spacing: 7,
        multiplier: 5
    )
    @State private var repWheelConfig: WheelPicker.Config = .init(
        count: 100,
        steps: 1,
        spacing: 50,
        multiplier: 1
    )
    
    @State private var exertionWheelConfig: WheelPicker.Config = .init(
        count: 10,
        steps: 1,
        spacing: 50,
        multiplier: 10
    )
    
    @State private var exerciseStates: [ExerciseState] = []
    @State private var currentIndex: Int = 0
    @State private var showExerciseListView: Bool = false
    @State private var isLoading: Bool = true
    @State private var arrowOffset: CGFloat = -60
    let userId: String = "your_user_id" // Replace this with your actual user ID logic

    var body: some View {
        let colors: [Color] = [Color(hex: "d4e09b"),
                               Color(hex: "f6f4d2"),
                               Color(hex: "cbdfbd"),
                               Color(hex: "f19c79")]

        ZStack {
            if isLoading {
                Text("Loading...")
                    .onAppear {
                        loadExercisesFromFirebase()
                    }
            } else if exerciseStates.isEmpty {
                VStack {
                    // add a cute image here
                    Text("Start adding exercises!")
                    
                }
            } else {
                VerticalPager(pageCount: exerciseStates.count, currentIndex: $currentIndex) {
                    ForEach(exerciseStates.indices, id: \.self) { index in
                        ExerciseView(
                            state: $exerciseStates[index],
                            exerciseName: $exerciseStates[index].exerciseName,
                            weightWheelConfig: weightWheelConfig,
                            repWheelConfig: repWheelConfig,
                            RPEWheelConfig: exertionWheelConfig,
                            color: colors[index % colors.count],
                            userId: userId
                        ).onAppear {
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
                            .frame(width: 30, height: 50)
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
            ExerciseListView(exerciseStates: $exerciseStates, userId: userId, startBouncingArrow: startBouncingArrow)
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
                self.isLoading = false
            }
        }
    }
    
    func loadCurrentState(for exerciseName: String, at index: Int) {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userId)
            
            userRef.collection("currentState").document(exerciseName).getDocument { document, error in
                if let error = error {
                    print("Error loading current state: \(error)")
                } else if let document = document, document.exists {
                    let data = document.data()
                    DispatchQueue.main.async {
                        exerciseStates[index].lastWeightValue = data?["lastWeightValue"] as? Double ?? 0
                        exerciseStates[index].lastRepValue = data?["lastRepValue"] as? Double ?? 0
                        exerciseStates[index].lastRPEValue = data?["lastRPEValue"] as? Double ?? 0
                        exerciseStates[index].setCount = data?["setCount"] as? Int ?? 0
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

struct ExerciseListView: View {
    @Binding var exerciseStates: [ExerciseState]
    @State private var newExerciseName: String = ""
    @Environment(\.presentationMode) var presentationMode
    let userId: String
    let startBouncingArrow: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add New Exercise")) {
                        TextField("Exercise Name", text: $newExerciseName)
                        Button("Add Exercise") {
                            if !newExerciseName.isEmpty {
                                let newExercise = ExerciseState(
                                    exerciseName: newExerciseName,
                                    lastWeightValue: 0,
                                    lastRepValue: 0,
                                    lastRPEValue: 0,
                                    setCount: 0,
                                    showCheckmark: false
                                )
                                exerciseStates.append(newExercise)
                                addExerciseToFirebase(userId: userId, exerciseName: newExerciseName)
                                newExerciseName = ""
                            }
                        }
                    }
                    
                    Section(header: Text("My Exercises")) {
                        ForEach(exerciseStates.indices, id: \.self) { index in
                            HStack {
                                Text(exerciseStates[index].exerciseName)
                                Spacer()
                                Button(action: {
                                    removeExerciseFromFirebase(userId: userId, exerciseName: exerciseStates[index].exerciseName)
                                    exerciseStates.remove(at: index)
                                    startBouncingArrow() // Restart animation after deletion
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle()) // Ensure only the icon is tappable
                                
                                Image(systemName: "line.horizontal.3")
                                    .padding(.leading)
                                
                            }
                        }
                        .onMove(perform: move)
                    }
                }
                .navigationTitle("Manage Exercises")
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
            .preferredColorScheme(.dark) // Force dark mode only here
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        exerciseStates.move(fromOffsets: source, toOffset: destination)
    }

    func addExerciseToFirebase(userId: String, exerciseName: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.collection("exercises").document(exerciseName).setData([
            "exerciseName": exerciseName
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }

    func removeExerciseFromFirebase(userId: String, exerciseName: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.collection("exercises").document(exerciseName).delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document removed successfully")
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00ff00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000ff) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    ContentView()
}
