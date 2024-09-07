import SwiftUI
import SwiftData

struct LogbookView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var groupedExerciseHistory: [String: [Date: [ExerciseHistory]]] = [:]
    @State private var selectedExerciseIndex: Int = 0 // Track the index of the current exercise
    private var exercises: [String] {
        Array(groupedExerciseHistory.keys.sorted())
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Exercise Logbook")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .padding(.leading, 16)
                .padding(.top, 32)

            if exercises.isEmpty {
                Text("No exercise history available")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.leading, 16)
            } else {
                // Carousel-like TabView for exercises
                TabView(selection: $selectedExerciseIndex) {
                    ForEach(0..<exercises.count, id: \.self) { index in
                        ExerciseCarouselCard(exerciseName: exercises[index], exerciseHistory: groupedExerciseHistory[exercises[index]] ?? [:])
                            .padding(.horizontal, 20)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 600) // Adjust height to fit content
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            loadAllExerciseHistory()
        }
    }

    // Loading all exercise history and grouping by exercise name and date
    private func loadAllExerciseHistory() {
        let fetchRequest = FetchDescriptor<ExerciseHistory>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let allHistory = try modelContext.fetch(fetchRequest)
            groupedExerciseHistory = Dictionary(grouping: allHistory) { history in
                history.exerciseName
            }.mapValues { histories in
                Dictionary(grouping: histories) { history in
                    Calendar.current.startOfDay(for: history.timestamp)
                }
            }
            // Start with the first exercise tab selected
            selectedExerciseIndex = 0
        } catch {
            print("Failed to load exercise history: \(error)")
        }
    }
}

// A single carousel card for each exercise
struct ExerciseCarouselCard: View {
    let exerciseName: String
    let exerciseHistory: [Date: [ExerciseHistory]]

    var body: some View {
        VStack {
            Text(exerciseName)
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .padding(.top, 20)

            ScrollView {
                ForEach(Array(exerciseHistory.keys.sorted(by: >)), id: \.self) { date in
                    Section(header: Text(formattedDate(date))
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.leading, 16)) {
                        ForEach(exerciseHistory[date]!) { history in
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Weight: \(history.weight, specifier: "%.1f") lbs")
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Text("Reps: \(history.reps, specifier: "%.0f")")
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Text("RPE: \(history.rpe, specifier: "%.0f")%")
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Text("Time: \(formattedTime(history.timestamp))")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Color(.darkGray))
                            .cornerRadius(10)
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
        .background(Color(.black).cornerRadius(15))
        .shadow(radius: 10)
        .padding(.top, 20)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
