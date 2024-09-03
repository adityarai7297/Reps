import SwiftData
import SwiftUI

@Model
final class ExerciseHistory {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise
    var weight: CGFloat
    var reps: CGFloat
    var rpe: CGFloat
    var timestamp: Date

    init(exercise: Exercise, weight: CGFloat, reps: CGFloat, rpe: CGFloat, timestamp: Date = Date()) {
        self.id = UUID() // Ensure each instance gets a unique UUID
        self.exercise = exercise
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
        self.timestamp = timestamp
    }
}
