import SwiftUI
import SwiftData

struct BodyMapView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExerciseHistory.timestamp, order: .reverse) private var exerciseHistories: [ExerciseHistory]
    @Query private var exercises: [Exercise]
    
    private var last10DaysExercises: [(Date, [ExerciseHistory])] {
        let calendar = Calendar.current
        let today = Date()
        let last10Days = (0..<10).compactMap { days in
            calendar.date(byAdding: .day, value: -days, to: today)
        }
        
        return last10Days.map { date in
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let dayExercises = exerciseHistories.filter { history in
                history.timestamp >= startOfDay && history.timestamp < endOfDay
            }
            return (startOfDay, dayExercises)
        }
    }
    
    private func getMuscleGroups(for exerciseName: String) -> [String] {
        if let exercise = exercises.first(where: { $0.name == exerciseName }) {
            return exercise.targetedMuscleGroups
        }
        return []
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(last10DaysExercises, id: \.0) { date, histories in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(formattedDate(date))
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                if histories.isEmpty {
                                    Text("No exercises")
                                        .foregroundColor(.gray)
                                        .italic()
                                } else {
                                    ForEach(histories) { history in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(history.exerciseName)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            let muscleGroups = getMuscleGroups(for: history.exerciseName)
                                            if !muscleGroups.isEmpty {
                                                HStack {
                                                    ForEach(muscleGroups, id: \.self) { muscle in
                                                        Text(muscle)
                                                            .font(.system(size: 12))
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(Color.white.opacity(0.2))
                                                            .cornerRadius(8)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            if date != last10DaysExercises.last?.0 {
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Recent Exercises")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
} 
