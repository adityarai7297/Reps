import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    
    private init() {
        // Initialize Firebase if not already initialized
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    func saveUserOnboardingData(_ data: UserOnboardingData) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let userData: [String: Any] = [
            "trainingLevel": data.trainingLevel,
            "primaryGoals": data.primaryGoals,
            "trainingDaysPerWeek": data.trainingDaysPerWeek,
            "workoutSplit": data.workoutSplit,
            "availableEquipment": data.availableEquipment,
            "focusAreas": data.focusAreas,
            "trainingIntensity": data.trainingIntensity,
            "hasInjuries": data.hasInjuries,
            "preferredTrainingStyles": data.preferredTrainingStyles,
            "completedOnboarding": true,
            "createdAt": Timestamp(date: data.createdAt)
        ]
        
        try await db.collection("users").document(uid).setData(userData, merge: true)
    }
} 