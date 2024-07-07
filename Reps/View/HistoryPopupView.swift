import SwiftUI
import FirebaseFirestore

struct HistoryPopupView: View {
    @Binding var state: ExerciseState
    @Binding var historyEntries: [HistoryEntry] // Make it a binding
    let exerciseName: String
    let userId: String
    @Environment(\.presentationMode) var presentationMode // Add this to handle sheet closing

    var body: some View {
        VStack {
            List {
                ForEach(historyEntries) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Weight: \(String(format: "%.1f", entry.weight)) lbs")
                            Text("Reps: \(Int(entry.reps))")
                            Text("RPE: \(Int(entry.RPE))%")
                            Text("Time: \(entry.timestamp, style: .time)") // Only show time of day
                        }

                        Spacer()

                        Button(action: {
                            deleteEntry(entry: entry)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .padding(.leading, 5)
                    }
                    .padding(.vertical, 5)
                }
            }

            Button("Close") {
                presentationMode.wrappedValue.dismiss() // Close the sheet
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .cornerRadius(20)
        .shadow(radius: 20)
    }

    func deleteEntry(entry: HistoryEntry) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.collection("history").document(entry.id).delete { error in
            if let error = error {
                print("Error deleting Set: \(error)")
            } else {
                print("Set successfully deleted")
                // Remove the deleted entry from the historyEntries list
                if let index = historyEntries.firstIndex(where: { $0.id == entry.id }) {
                    historyEntries.remove(at: index)
                }
                state.setCount = max(state.setCount - 1, 0)
            }
        }
    }
}

struct HistoryEntry: Identifiable {
    let id: String // Using the document ID from Firebase
    let weight: Double
    let reps: Double
    let RPE: Double
    let timestamp: Date
}
