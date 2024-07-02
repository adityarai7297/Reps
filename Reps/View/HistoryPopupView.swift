import SwiftUI
import FirebaseFirestore

struct HistoryPopupView: View {
    let historyEntries: [HistoryEntry]
    let exerciseName: String
    let userId: String
    @Environment(\.presentationMode) var presentationMode // Add this to handle sheet closing

    var body: some View {
        VStack {
            Text("History for \(exerciseName)")
                .font(.headline)
                .padding()

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
        //.frame(maxWidth: .infinity, maxHeight: .infinity)
        //.background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
        //.padding()
    }

    func deleteEntry(entry: HistoryEntry) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.collection("history").document(entry.id).delete { error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Document successfully deleted")
                // Optionally, you can refresh the historyEntries state here or inform the parent view to refresh
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
