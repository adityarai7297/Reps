import SwiftData
import SwiftUI

@Model
final class ExerciseHistory {
    @Attribute(.unique) var id: UUID
    var exerciseName: String // Store exercise name directly
    var weight: CGFloat
    var reps: CGFloat
    var rpe: CGFloat
    var timestamp: Date

    init(exerciseName: String, weight: CGFloat, reps: CGFloat, rpe: CGFloat, timestamp: Date = Date()) {
        self.id = UUID() // Ensure each instance gets a unique UUID
        self.exerciseName = exerciseName // Save the exercise name directly
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
        self.timestamp = timestamp
    }
}
