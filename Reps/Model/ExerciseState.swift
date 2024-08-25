import SwiftData
import SwiftUI

@Model
final class ExerciseState {
    var exerciseName: String
    var lastWeightValue: CGFloat
    var lastRepValue: CGFloat
    var lastRPEValue: CGFloat
    var setCount: Int
    var showCheckmark: Bool
    
    init(exerciseName: String, lastWeightValue: CGFloat, lastRepValue: CGFloat, lastRPEValue: CGFloat, setCount: Int, showCheckmark: Bool) {
        self.exerciseName = exerciseName
        self.lastWeightValue = lastWeightValue
        self.lastRepValue = lastRepValue
        self.lastRPEValue = lastRPEValue
        self.setCount = setCount
        self.showCheckmark = showCheckmark
    }
}
