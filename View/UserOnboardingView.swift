import SwiftUI
import SwiftData

// MARK: - Models
struct OnboardingQuestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let options: [String]
    let allowsMultipleSelection: Bool
    let minimumSelections: Int
}

// MARK: - Supporting Views
struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * CGFloat(currentStep) / CGFloat(totalSteps))
            }
            .clipShape(Capsule())
        }
    }
}

struct OptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
            )
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
    }
}

// MARK: - UserOnboardingView
struct UserOnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var selectedOptions: [String: Set<String>] = [:]
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    var onComplete: (() -> Void)?
    
    // Define all onboarding questions
    let questions: [OnboardingQuestion] = [
        OnboardingQuestion(
            title: "What is your current level of training?",
            options: ["Beginner", "Intermediate", "Advanced"],
            allowsMultipleSelection: false,
            minimumSelections: 1
        ),
        OnboardingQuestion(
            title: "What are your primary goals?",
            options: [
                "Increasing Overall Strength",
                "Muscle Hypertrophy",
                "Power Development",
                "Endurance",
                "Weight Loss"
            ],
            allowsMultipleSelection: true,
            minimumSelections: 1
        ),
        OnboardingQuestion(
            title: "How many days per week can you train?",
            options: ["1-2", "3-4", "5+"],
            allowsMultipleSelection: false,
            minimumSelections: 1
        ),
        OnboardingQuestion(
            title: "What equipment do you have access to?",
            options: [
                "Commercial Gym",
                "Home Gym",
                "Resistance Bands",
                "Bodyweight Only",
                "Free Weights"
            ],
            allowsMultipleSelection: true,
            minimumSelections: 1
        ),
        OnboardingQuestion(
            title: "Do you have any injuries or limitations?",
            options: ["Yes", "No"],
            allowsMultipleSelection: false,
            minimumSelections: 1
        ),
        OnboardingQuestion(
            title: "Preferred Training Style",
            options: [
                "Traditional Strength Training",
                "High-Intensity Interval Training",
                "Circuit Training",
                "Powerlifting",
                "Bodybuilding"
            ],
            allowsMultipleSelection: true,
            minimumSelections: 1
        ),
        OnboardingQuestion(
            title: "Preferred Training Split",
            options: [
                "Bro Split",
                "Push/Pull/Legs",
                "Upper/Lower",
                "Full Body",
                "Arms Legs Torso",
                "Vertical/Horizontal Push/pull"
            ],
            allowsMultipleSelection: true,
            minimumSelections: 1
        ),
        OnboardingQuestion(
            title: "Preferred Training Equipment",
            options: [
                "Barbell",
                "Dumbbell",
                "Kettlebell",
                "Cable",
                "Machine",
                "Resistance Bands",
                "Bodyweight Only"
            ],
            allowsMultipleSelection: true,
            minimumSelections: 1
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [.purple.opacity(0.15), .blue.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress bar
                    ProgressBar(currentStep: currentPage + 1, totalSteps: questions.count)
                        .frame(height: 4)
                        .padding(.top, 60)
                        .padding(.horizontal)
                    
                    // Current question
                    let question = questions[currentPage]
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text(question.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.top, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(question.options, id: \.self) { option in
                                    OptionButton(
                                        title: option,
                                        isSelected: selectedOptions[question.title]?.contains(option) ?? false,
                                        action: {
                                            toggleOption(option, for: question)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(minHeight: geometry.size.height - 200)
                    }
                    
                    // Navigation buttons
                    VStack(spacing: 16) {
                        // Selection hint
                        if !isCurrentQuestionValid() {
                            Text("Select at least \(question.minimumSelections) option\(question.minimumSelections > 1 ? "s" : "")")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        // Buttons
                        HStack(spacing: 20) {
                            if currentPage > 0 {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPage -= 1
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Previous")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(.ultraThinMaterial)
                                    )
                                }
                            }
                            
                            if currentPage < questions.count - 1 {
                                Button(action: {
                                    if isCurrentQuestionValid() {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            currentPage += 1
                                        }
                                    } else {
                                        showingAlert = true
                                        alertMessage = "Please select at least \(question.minimumSelections) option\(question.minimumSelections > 1 ? "s" : "")"
                                    }
                                }) {
                                    HStack {
                                        Text("Next")
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(isCurrentQuestionValid() ? .ultraThinMaterial : .ultraThinMaterial.opacity(0.5))
                                    )
                                }
                                .disabled(!isCurrentQuestionValid())
                            } else {
                                Button(action: {
                                    if isCurrentQuestionValid() {
                                        saveOnboardingData()
                                    } else {
                                        showingAlert = true
                                        alertMessage = "Please select at least \(question.minimumSelections) option\(question.minimumSelections > 1 ? "s" : "")"
                                    }
                                }) {
                                    HStack {
                                        Text("Complete")
                                        Image(systemName: "checkmark")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(isCurrentQuestionValid() ? .ultraThinMaterial : .ultraThinMaterial.opacity(0.5))
                                    )
                                }
                                .disabled(!isCurrentQuestionValid())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                    )
                }
                
                if isLoading {
                    LoadingView()
                }
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Required"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func toggleOption(_ option: String, for question: OnboardingQuestion) {
        var currentSelection = selectedOptions[question.title] ?? Set<String>()
        
        if question.allowsMultipleSelection {
            if currentSelection.contains(option) {
                currentSelection.remove(option)
            } else {
                currentSelection.insert(option)
            }
        } else {
            currentSelection = [option]
        }
        
        selectedOptions[question.title] = currentSelection
    }
    
    private func isCurrentQuestionValid() -> Bool {
        let question = questions[currentPage]
        let selectedCount = selectedOptions[question.title]?.count ?? 0
        return selectedCount >= question.minimumSelections
    }
    
    private func saveOnboardingData() {
        isLoading = true
        
        let onboardingData = UserOnboardingData(
            trainingLevel: selectedOptions["What is your current level of training?"]?.first ?? "",
            primaryGoals: Array(selectedOptions["What are your primary goals?"] ?? []),
            trainingDaysPerWeek: selectedOptions["How many days per week can you train?"]?.first ?? "",
            availableEquipment: Array(selectedOptions["What equipment do you have access to?"] ?? []),
            hasInjuries: selectedOptions["Do you have any injuries or limitations?"]?.contains("Yes") ?? false,
            preferredTrainingStyles: Array(selectedOptions["Preferred Training Style"] ?? [])
        )
        
        modelContext.insert(onboardingData)
        
        do {
            try modelContext.save()
            onComplete?()
            dismiss()
        } catch {
            showingAlert = true
            alertMessage = "Failed to save: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
} 