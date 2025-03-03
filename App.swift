import SwiftUI
import FirebaseCore
import os

let logger = Logger(subsystem: "com.reps.app", category: "debug")

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Basic print statement to verify debug console
        print("DEBUG TEST: App is starting...")
        print("DEBUG TEST: Will try to configure Firebase now")
        logger.debug("App delegate initialized")
        
        // Check if already configured
        if FirebaseApp.app() != nil {
            print("DEBUG TEST: Firebase was already configured")
            return true
        }
        
        // Configure Firebase
        do {
            FirebaseApp.configure()
            print("DEBUG TEST: Firebase configuration completed")
            
            // Verify Firestore is accessible
            let db = Firestore.firestore()
            print("DEBUG TEST: Got Firestore instance")
            
            // Try to access Firestore to verify connection
            Task {
                do {
                    print("DEBUG TEST: Will try to access Firestore...")
                    let _ = try await db.collection("test").document("test").getDocument()
                    print("DEBUG TEST: Successfully accessed Firestore!")
                } catch {
                    print("DEBUG TEST: Failed to access Firestore - \(error.localizedDescription)")
                }
            }
        } catch {
            print("DEBUG TEST: Firebase configuration failed - \(error.localizedDescription)")
        }
        
        return true
    }
}

@main
struct RepsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        print("DEBUG TEST: RepsApp init called")
        print("DEBUG TEST: If you can see this, debug console is working!")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("DEBUG TEST: ContentView appeared")
                }
        }
    }
} 