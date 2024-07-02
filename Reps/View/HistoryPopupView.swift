import SwiftUI

struct HistoryPopupView: View {
    let historyEntries: [HistoryEntry]
    @Environment(\.presentationMode) var presentationMode // Add this to handle sheet closing

    var body: some View {
        VStack {
            List(historyEntries) { entry in
                VStack(alignment: .leading) {
                    Text("Weight: \(String(format: "%.1f", entry.weight)) lbs")
                                        Text("Reps: \(Int(entry.reps))")
                                        Text("RPE: \(Int(entry.RPE))%")
                                        Text("Time: \(entry.timestamp, style: .time)")
                }
                //.padding()
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
        //.shadow(radius: 10)
        //.padding()
    }
}

struct HistoryEntry: Identifiable {
    let id = UUID()
    let weight: Double
    let reps: Double
    let RPE: Double
    let timestamp: Date
}
