import SwiftData
import SwiftUI

@Model
final class Exercise {
    var id = UUID()
    var name: String
    var history: [ExerciseHistory] // Relationship to track the history of this exercise

    init(name: String) {
        self.name = name
        self.history = []
    }
}
