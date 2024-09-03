import SwiftData
import SwiftUI

@Model
final class ExerciseHistory {
    var id = UUID()
    var exercise: Exercise // Relationship to the Exercise entity
    var weight: CGFloat
    var reps: CGFloat
    var rpe: CGFloat
    var timestamp: Date

    init(exercise: Exercise, weight: CGFloat, reps: CGFloat, rpe: CGFloat, timestamp: Date = Date()) {
        self.exercise = exercise
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
        self.timestamp = timestamp
    }
}
