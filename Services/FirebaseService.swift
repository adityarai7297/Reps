import FirebaseFirestore
import FirebaseAuth
import FirebaseApp
import FirebaseCore
import os

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let logger = Logger(subsystem: "com.reps.app", category: "firebase")
    
    init() {
        print("DEBUG TEST: FirebaseService initialized")
        // Check if Firebase is initialized
        if FirebaseApp.app() == nil {
            print("DEBUG TEST: ⚠️ Firebase is NOT initialized in FirebaseService")
        } else {
            print("DEBUG TEST: ✅ Firebase IS initialized in FirebaseService")
        }
    }
    
    func isUserAuthenticated() -> Bool {
        if let user = Auth.auth().currentUser {
            print("✅ User is authenticated with ID: \(user.uid)")
            return true
        } else {
            print("❌ No authenticated user")
            return false
        }
    }
    
    func signInAnonymously() async throws {
        print("🔑 Attempting anonymous sign in...")
        let result = try await Auth.auth().signInAnonymously()
        print("✅ Anonymous sign in successful with user ID: \(result.user.uid)")
    }
    
    func saveUserOnboardingData(_ data: UserOnboardingData) async throws {
        print("\nDEBUG TEST: Starting onboarding data save...")
        logger.debug("Attempting to save onboarding data")
        
        // Check Firebase initialization
        if FirebaseApp.app() == nil {
            print("DEBUG TEST: Firebase is not initialized!")
            throw NSError(domain: "FirebaseService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Firebase is not initialized"])
        }
        
        // Use a fixed document ID for now
        let documentId = "onboarding_data"
        print("DEBUG TEST: Will save to document ID: \(documentId)")
        
        let onboardingData: [String: Any] = [
            "trainingLevel": data.trainingLevel,
            "primaryGoals": data.primaryGoals,
            "trainingDaysPerWeek": data.trainingDaysPerWeek,
            "workoutSplit": data.workoutSplit,
            "availableEquipment": data.availableEquipment,
            "focusAreas": data.focusAreas,
            "trainingIntensity": data.trainingIntensity,
            "hasInjuries": data.hasInjuries,
            "preferredTrainingStyles": data.preferredTrainingStyles,
            "completedOnboarding": data.completedOnboarding,
            "createdAt": data.createdAt,
            "updatedAt": Date()
        ]
        
        print("DEBUG TEST: Data prepared for upload:")
        print(onboardingData)
        
        do {
            // Get a reference to the document
            let docRef = db.collection("onboarding").document(documentId)
            print("DEBUG TEST: Got reference to document: onboarding/\(documentId)")
            
            print("DEBUG TEST: Attempting to write data...")
            // Write the data
            try await docRef.setData(onboardingData, merge: true)
            print("DEBUG TEST: Write operation completed")
            
            // Verify the write immediately
            print("DEBUG TEST: Verifying write operation...")
            let verifyDoc = try await docRef.getDocument()
            
            if verifyDoc.exists {
                print("DEBUG TEST: Document exists after write!")
                if let data = verifyDoc.data() {
                    print("DEBUG TEST: Retrieved data:")
                    print(data)
                }
            } else {
                print("DEBUG TEST: Document does NOT exist after write!")
                throw NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Data was not saved - document does not exist"])
            }
            
            print("DEBUG TEST: Save operation completed successfully!")
            logger.debug("Save operation successful")
        } catch {
            print("DEBUG TEST: ERROR during save operation!")
            print("DEBUG TEST: Error description: \(error.localizedDescription)")
            print("DEBUG TEST: Full error: \(error)")
            logger.error("Save operation failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getUserOnboardingData() async throws -> UserOnboardingData? {
        let documentId = "onboarding_data"
        let document = try await db.collection("onboarding").document(documentId).getDocument()
        
        guard let data = document.data() else {
            return nil
        }
        
        return UserOnboardingData(
            trainingLevel: data["trainingLevel"] as? String ?? "",
            primaryGoals: data["primaryGoals"] as? [String] ?? [],
            trainingDaysPerWeek: data["trainingDaysPerWeek"] as? String ?? "",
            workoutSplit: data["workoutSplit"] as? String ?? "",
            availableEquipment: data["availableEquipment"] as? [String] ?? [],
            focusAreas: data["focusAreas"] as? [String] ?? [],
            trainingIntensity: data["trainingIntensity"] as? String ?? "",
            hasInjuries: data["hasInjuries"] as? Bool ?? false,
            preferredTrainingStyles: data["preferredTrainingStyles"] as? [String] ?? []
        )
    }
}