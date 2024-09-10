import SwiftUI
import SwiftData

struct LogbookView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var groupedExerciseHistory: [String: [Date: [ExerciseHistory]]] = [:]
    @State private var groupedByDate: [Date: [ExerciseHistory]] = [:] // New state for grouping by date
    @State private var selectedTab: Int = 0 // Track which tab is selected
    @State private var selectedExerciseIndex: Int = 0 // Track the index of the current exercise

    private var exercises: [String] {
        Array(groupedExerciseHistory.keys.sorted())
    }

    private var dates: [Date] {
        groupedByDate.keys.sorted(by: >) // Sort dates in descending order
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Exercise Logbook")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
                .padding(.leading, 16)
                .padding(.top, 32)

            if exercises.isEmpty {
                Text("No exercise history available")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.leading, 16)
            } else {
                TabView(selection: $selectedTab) {
                    // "By Exercise" tab
                    VStack {
                        if exercises.isEmpty {
                            Text("No exercise history available")
                                .foregroundColor(.gray)
                                .font(.headline)
                                .padding(.top, 20)
                                .padding(.leading, 16)
                        } else {
                            TabView(selection: $selectedExerciseIndex) {
                                ForEach(0..<exercises.count, id: \.self) { index in
                                    ExerciseCarouselCard(exerciseName: exercises[index], exerciseHistory: groupedExerciseHistory[exercises[index]] ?? [:])
                                        .padding(.horizontal, 2)
                                        .tag(index)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                            .frame(height: 600) // Adjust height to fit content
                        }
                    }
                    .tag(0)
                    .tabItem {
                        Label("By Exercise", systemImage: "list.bullet")
                    }

                    // "By Day" tab
                    VStack {
                        ScrollView {
                            ForEach(dates, id: \.self) { date in
                                Section(header: Text(formattedDate(date))
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 16)) {
                                    ForEach(groupedByDate[date] ?? []) { history in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Exercise: \(history.exerciseName)")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)

                                                Text("Weight: \(history.weight, specifier: "%.1f") lbs")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)

                                                Text("Reps: \(history.reps, specifier: "%.0f")")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)

                                                Text("RPE: \(history.rpe, specifier: "%.0f")%")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)

                                                Text("Time: \(formattedTime(history.timestamp))")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }
                        }
                    }
                    .tag(1)
                    .tabItem {
                        Label("By Day", systemImage: "calendar")
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
        }
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

            // Group by exercise name
            groupedExerciseHistory = Dictionary(grouping: allHistory) { history in
                history.exerciseName
            }.mapValues { histories in
                Dictionary(grouping: histories) { history in
                    Calendar.current.startOfDay(for: history.timestamp)
                }
            }

            // Group by date
            groupedByDate = Dictionary(grouping: allHistory) { history in
                Calendar.current.startOfDay(for: history.timestamp)
            }

            selectedExerciseIndex = 0
        } catch {
            print("Failed to load exercise history: \(error)")
        }
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

// A single carousel card for each exercise
struct ExerciseCarouselCard: View {
    let exerciseName: String
    let exerciseHistory: [Date: [ExerciseHistory]] // Grouped exercise history by date

    var body: some View {
        VStack {
            Text(exerciseName)
                .font(.largeTitle.bold())
                .foregroundColor(.primary) // Uses dynamic color for text
                .padding(.top, 20)

            ScrollView {
                ForEach(Array(exerciseHistory.keys.sorted(by: >)), id: \.self) { date in
                    Section(header: Text(formattedDate(date))
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.leading, 16)) {
                        ForEach(exerciseHistory[date]!) { history in
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Weight: \(history.weight, specifier: "%.1f") lbs")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text("Reps: \(history.reps, specifier: "%.0f")")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text("RPE: \(history.rpe, specifier: "%.0f")%")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text("Time: \(formattedTime(history.timestamp))")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground)) // Dynamic background for list items
                            .cornerRadius(10)
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground)) // Use system background for the card as well
        .cornerRadius(15)
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
