import SwiftData
import SwiftUI

@Model
final class Exercise  {
    @Attribute(.unique) var id: UUID
    var name: String
    var history: [ExerciseHistory] = []
    var targetedMuscleGroups: [String] = []

    init(name: String, targetedMuscleGroups: [String] = []) {
        self.id = UUID()
        self.name = name
        self.targetedMuscleGroups = targetedMuscleGroups
    }
}
