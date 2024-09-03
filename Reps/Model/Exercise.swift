import SwiftData
import SwiftUI

@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var history: [ExerciseHistory] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
