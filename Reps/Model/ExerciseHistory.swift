import SwiftData
import SwiftUI

@Model
final class ExerciseHistory: ObservableObject, Identifiable {
    @Attribute(.unique) var id: UUID
    var exerciseName: String
    var weight: CGFloat
    var reps: CGFloat
    var rpe: CGFloat
    var timestamp: Date

    // Initialization
    init(exerciseName: String, weight: CGFloat, reps: CGFloat, rpe: CGFloat, timestamp: Date = Date()) {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
        self.timestamp = timestamp
    }
}
