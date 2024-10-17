import SwiftUI
import SwiftData

struct EditExerciseHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var history: ExerciseHistory

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Weight
                VStack(alignment: .leading, spacing: 5) {
                    Text("Weight")
                        .font(.headline)
                        .foregroundColor(.white)  // Set label color to white
                    HStack {
                        TextField("Weight", value: $history.weight, formatter: numberFormatter)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .foregroundColor(.white)  // Set text color to white
                            .accentColor(.white)       // Set cursor color to white
                            .frame(maxWidth: .infinity)
                        Text("lbs")
                            .foregroundColor(.secondary)
                    }
                }
                // Reps
                VStack(alignment: .leading, spacing: 5) {
                    Text("Reps")
                        .font(.headline)
                        .foregroundColor(.white)  // Set label color to white
                    TextField("Reps", value: $history.reps, formatter: numberFormatter)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.white)  // Set text color to white
                        .accentColor(.white)       // Set cursor color to white
                }
                // RPE
                VStack(alignment: .leading, spacing: 5) {
                    Text("RPE")
                        .font(.headline)
                        .foregroundColor(.white)  // Set label color to white
                    HStack {
                        TextField("RPE", value: $history.rpe, formatter: numberFormatter)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .foregroundColor(.white)  // Set text color to white
                            .accentColor(.white)       // Set cursor color to white
                            .frame(maxWidth: .infinity)
                        Text("%")
                            .foregroundColor(.secondary)
                    }
                }
                // Save button
                Button(action: {
                    saveChanges()
                    dismiss()
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                Spacer()
            }
            .padding()
            .background(Color.black)  // Set background to black
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save edited exercise history: \(error)")
        }
    }

    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter
    }
}
