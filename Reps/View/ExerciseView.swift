import SwiftUI
import FirebaseFirestore

struct ExerciseView: View {
    @Binding var state: ExerciseState
    @Binding var exerciseName: String
    let weightWheelConfig: WheelPicker.Config
    let repWheelConfig: WheelPicker.Config
    let RPEWheelConfig: WheelPicker.Config
    let color: Color
    let userId: String
    @State private var showHistoryPopup = false
    @State private var historyEntries: [HistoryEntry] = []

    var body: some View {
        VStack {
            VStack {
                Spacer().frame(height: 40)
                Text(exerciseName)
                    .font(.largeTitle.bold())
                Spacer().frame(height: 40)

                Rectangle()
                    .frame(height: 0.3)

                Spacer().frame(height: 60)

                VStack{
                    HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                        Text(verbatim: "\(state.lastWeightValue)")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: state.lastWeightValue))
                            .animation(.snappy, value: state.lastWeightValue)

                        Text("lbs")
                            .font(.title2)
                            .fontWeight(.light)
                            .textScale(.secondary)
                    })

                    WheelPicker(config: weightWheelConfig, value: $state.lastWeightValue)
                        .frame(height: 60)
                }

                Spacer().frame(height: 40)

                VStack{
                    HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                        Text(verbatim: "\(Int(state.lastRepValue))")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: state.lastRepValue))
                            .animation(.snappy, value: state.lastRepValue)

                        Text("reps")
                            .font(.title2)
                            .fontWeight(.light)
                            .textScale(.secondary)
                    })

                    WheelPicker(config: repWheelConfig, value: $state.lastRepValue)
                        .frame(height: 60)
                }

                Spacer().frame(height: 40)

                VStack{
                    HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                        Text(verbatim: "\(Int(state.lastRPEValue))")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: state.lastRPEValue))
                            .animation(.snappy, value: state.lastRPEValue)

                        Text("%  RPE")
                            .font(.title2)
                            .fontWeight(.light)
                            .textScale(.secondary)
                    })

                    WheelPicker(config: RPEWheelConfig, value: $state.lastRPEValue)
                        .frame(height: 60)
                }
            }
            .offset(y: state.showCheckmark ? -60 : 0)

            Spacer().frame(height: 60)

            HStack {
                Spacer().frame(width: 100)
                SetButton(showCheckmark: $state.showCheckmark, setCount: $state.setCount, action: {
                    state.setCount += 1
                    saveExerciseData(userId: userId, exerciseName: state.exerciseName, weight: state.lastWeightValue, reps: state.lastRepValue, RPE: state.lastRPEValue, setCount: state.setCount)
                })
                Spacer().frame(width: 30)
                HStack{
                    Text("\(state.setCount)")
                        .font(.title)

                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)

                }
                .opacity(state.setCount > 0 ? 1 : 0)
                .onTapGesture {
                    fetchHistory(for: state.exerciseName)
                    showHistoryPopup = true
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showHistoryPopup) {
            HistoryPopupView(state: $state, historyEntries: $historyEntries, exerciseName: state.exerciseName, userId: userId)
        }
    }

    func fetchHistory(for exerciseName: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.collection("history")
            .whereField("exerciseName", isEqualTo: exerciseName)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching history: \(error)")
                } else {
                    guard let documents = snapshot?.documents else { return }
                    self.historyEntries = documents.map { doc in
                        let data = doc.data()
                        return HistoryEntry(
                            id: doc.documentID, // Use the document ID as the ID
                            weight: data["weight"] as? Double ?? 0,
                            reps: data["reps"] as? Double ?? 0,
                            RPE: data["RPE"] as? Double ?? 0,
                            timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        )
                    }
                }
            }
    }

    func saveExerciseData(userId: String, exerciseName: String, weight: Double, reps: Double, RPE: Double, setCount: Int) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        // Save set data under 'history'
        userRef.collection("history").addDocument(data: [
            "exerciseName": exerciseName,
            "weight": weight,
            "reps": reps,
            "RPE": RPE,
            "timestamp": Timestamp()
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully to history")
            }
        }

        // Update 'lastState' in the 'exercises' collection
        let exerciseData: [String: Any] = [
            "exerciseName": exerciseName,
            "lastState": [
                "weight": weight,
                "reps": reps,
                "RPE": RPE,
                "timestamp": Timestamp(),
                "dailySetCount": setCount
            ]
        ]

        userRef.collection("exercises").document(exerciseName).setData(exerciseData, merge: true) { error in
            if let error = error {
                print("Error updating lastState: \(error)")
            } else {
                print("lastState updated successfully in exercises")
            }
        }
    }
}
