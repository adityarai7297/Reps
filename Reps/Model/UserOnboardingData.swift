import Foundation
import SwiftData

@Model
final class UserOnboardingData {
    var trainingLevel: String
    var primaryGoals: [String]
    var trainingDaysPerWeek: String
    var workoutSplit: String
    var availableEquipment: [String]
    var focusAreas: [String]
    var trainingIntensity: String
    var hasInjuries: Bool
    var preferredTrainingStyles: [String]
    var completedOnboarding: Bool
    var createdAt: Date
    
    init(
        trainingLevel: String = "",
        primaryGoals: [String] = [],
        trainingDaysPerWeek: String = "",
        workoutSplit: String = "",
        availableEquipment: [String] = [],
        focusAreas: [String] = [],
        trainingIntensity: String = "",
        hasInjuries: Bool = false,
        preferredTrainingStyles: [String] = []
    ) {
        self.trainingLevel = trainingLevel
        self.primaryGoals = primaryGoals
        self.trainingDaysPerWeek = trainingDaysPerWeek
        self.workoutSplit = workoutSplit
        self.availableEquipment = availableEquipment
        self.focusAreas = focusAreas
        self.trainingIntensity = trainingIntensity
        self.hasInjuries = hasInjuries
        self.preferredTrainingStyles = preferredTrainingStyles
        self.completedOnboarding = false
        self.createdAt = Date()
    }
}

// MARK: - Helper Methods
extension UserOnboardingData {
    func update(with selectedOptions: [String: Set<String>]) {
        if let trainingLevel = selectedOptions["What is your current level of training?"]?.first {
            self.trainingLevel = trainingLevel
        }
        
        if let goals = selectedOptions["What are your primary goals?"] {
            self.primaryGoals = Array(goals)
        }
        
        if let daysPerWeek = selectedOptions["How many days per week can you train?"]?.first {
            self.trainingDaysPerWeek = daysPerWeek
        }
        
        if let workoutSplit = selectedOptions["What's your preferred workout split?"]?.first {
            self.workoutSplit = workoutSplit
        }
        
        if let equipment = selectedOptions["What equipment do you have access to?"] {
            self.availableEquipment = Array(equipment)
        }
        
        if let focusAreas = selectedOptions["Which areas would you like to focus on?"] {
            self.focusAreas = Array(focusAreas)
        }
        
        if let trainingIntensity = selectedOptions["What's your preferred training intensity?"]?.first {
            self.trainingIntensity = trainingIntensity
        }
        
        if let hasInjuries = selectedOptions["Do you have any injuries or limitations?"]?.first {
            self.hasInjuries = hasInjuries == "Yes"
        }
        
        if let styles = selectedOptions["Preferred Training Style"] {
            self.preferredTrainingStyles = Array(styles)
        }
        
        self.completedOnboarding = true
    }
} 