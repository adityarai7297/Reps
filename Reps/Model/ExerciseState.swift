import SwiftData
import SwiftUI

@Model
final class ExerciseState {
    var exerciseName: String
    var lastWeightValue: CGFloat
    var lastRepValue: CGFloat
    var lastRPEValue: CGFloat
    var setCount: Int
    var timestamp: Date? // New property to store the timestamp
    
    init(exerciseName: String, lastWeightValue: CGFloat, lastRepValue: CGFloat, lastRPEValue: CGFloat, setCount: Int, timestamp: Date = Date()) {
        self.exerciseName = exerciseName
        self.lastWeightValue = lastWeightValue
        self.lastRepValue = lastRepValue
        self.lastRPEValue = lastRPEValue
        self.setCount = setCount
        self.timestamp = timestamp
    }
}
