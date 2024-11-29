import SwiftUI

class ExerciseState: ObservableObject {
    @Published var setCount: Int = 0
    @Published var currentWeight: CGFloat = 0
    @Published var currentReps: CGFloat = 0
    @Published var currentRPE: CGFloat = 0
    
    let exerciseId: UUID
    
    init(exerciseId: UUID) {
        self.exerciseId = exerciseId
    }
} 