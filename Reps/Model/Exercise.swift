import SwiftData
import SwiftUI

@Model
final class Exercise  {
    @Attribute(.unique) var id: UUID
    var name: String
    var history: [ExerciseHistory] = []
    private var _targetedMuscleGroups: [String] = []
    
    var targetedMuscleGroups: [MuscleGroup] {
        get {
            _targetedMuscleGroups.compactMap { MuscleGroup(rawValue: $0) }
        }
        set {
            _targetedMuscleGroups = newValue.map { $0.rawValue }
        }
    }

    init(name: String, targetedMuscleGroups: [MuscleGroup] = []) {
        self.id = UUID()
        self.name = name
        self._targetedMuscleGroups = targetedMuscleGroups.map { $0.rawValue }
    }
}
