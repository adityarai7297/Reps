import SwiftUI
import FirebaseCore
import FirebaseAuth
import SwiftData
import Foundation

// MARK: - Models
struct OnboardingQuestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let options: [String]
    let allowsMultipleSelection: Bool
    let type: QuestionType
    let minimumSelections: Int
    
    enum QuestionType {
        case singleChoice
        case multipleChoice
        case numberInput
        case textInput
    }
}

// MARK: - UserOnboardingData
struct UserOnboardingData: Codable {
    let trainingLevel: String
    let primaryGoals: [String]
    let trainingDaysPerWeek: String
    let availableEquipment: [String]
    let hasInjuries: Bool
    let preferredTrainingStyles: [String]
    let preferredTrainingSplit: [String]
    let preferredEquipment: [String]
}

// MARK: - UserOnboardingView
struct UserOnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var selectedOptions: [String: Set<String>] = [:]
    @State private var textInputs: [String: String] = [:]
    @State private var numberInputs: [String: Double] = [:]
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var navigationDirection: NavigationDirection = .forward
    var onComplete: (() -> Void)?
    
    enum NavigationDirection {
        case forward
        case backward
    }
    
    // Define all onboarding questions
    let questions: [OnboardingQuestion] = [
        OnboardingQuestion(
            title: "What is your current level of training?",
            options: ["Beginner", "Intermediate", "Advanced"],
            allowsMultipleSelection: false,
            type: .singleChoice,
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
            type: .multipleChoice,
            minimumSelections: 1
        ),
        OnboardingQuestion(
            title: "How many days per week can you train?",
            options: ["1-2", "3-4", "5+"],
            allowsMultipleSelection: false,
            type: .singleChoice,
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
            type: .multipleChoice,
            minimumSelections: 1
        ),
        OnboardingQuestion(
            title: "Do you have any injuries or limitations?",
            options: ["Yes", "No"],
            allowsMultipleSelection: false,
            type: .singleChoice,
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
            type: .multipleChoice,
            minimumSelections: 1
        ),
        OnboardingQuestion(
            title: "Preferred Training Split",
            options: [
                "Bro Split",
                "Push/Pull/Legs ",
                "Upper/Lower ",
                "Full Body",
                "Arms Legs Torso",
                "Vertical/Horizontal Push/pull"
            ],
            allowsMultipleSelection: true,
            type: .multipleChoice,
            minimumSelections: 1
        ),
        OnboardingQuestion(
            title: "Preferred Training equipment",
            options: [
                "Barbell",
                "Dumbbell",
                "Kettlebell",
                "Cable",
                "Machine",
                "Resistance Bands",
                "Bodyweight Only",
            ],
            allowsMultipleSelection: true,
            type: .multipleChoice,
            minimumSelections: 1
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [.purple.opacity(0.15), .blue.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Progress bar
                ProgressBar(currentStep: currentPage + 1, totalSteps: questions.count)
                    .padding(.top, 60)
                    .padding(.horizontal)
                
                // Question content
                ZStack {
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        if index == currentPage {
                            QuestionView(
                                question: question,
                                selectedOptions: selectedOptionsBinding(for: question.title),
                                textInput: textInputBinding(for: question.title),
                                numberInput: numberInputBinding(for: question.title)
                            )
                            .transition(.asymmetric(
                                insertion: navigationDirection == .forward ? .move(edge: .trailing) : .move(edge: .leading),
                                removal: navigationDirection == .forward ? .move(edge: .leading) : .move(edge: .trailing)
                            ))
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                Spacer()
                
                // Navigation Buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: {
                            navigationDirection = .backward
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.3))
                            )
                        }
                    }
                    
                    if currentPage < questions.count - 1 {
                        Button(action: {
                            if isCurrentQuestionValid() {
                                navigationDirection = .forward
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                showingAlert = true
                                alertMessage = "Please select at least one option"
                            }
                        }) {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(isCurrentQuestionValid() ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                            )
                        }
                        .disabled(!isCurrentQuestionValid())
                    } else {
                        Button(action: {
                            if isCurrentQuestionValid() {
                                navigationDirection = .forward
                                saveOnboardingData()
                            } else {
                                showingAlert = true
                                alertMessage = "Please select at least one option"
                            }
                        }) {
                            HStack {
                                Text("Finish")
                                Image(systemName: "checkmark")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(isCurrentQuestionValid() ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                            )
                        }
                        .disabled(!isCurrentQuestionValid())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            
            if isLoading {
                LoadingView()
            }
        }
        .navigationBarHidden(true)
        .alert("Required", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func isCurrentQuestionValid() -> Bool {
        let currentQuestion = questions[currentPage]
        let selectedCount = selectedOptions[currentQuestion.title]?.count ?? 0
        return selectedCount >= 1 // Require at least one selection
    }
    
    private func selectedOptionsBinding(for questionTitle: String) -> Binding<Set<String>> {
        return Binding(
            get: { self.selectedOptions[questionTitle] ?? Set<String>() },
            set: { self.selectedOptions[questionTitle] = $0 }
        )
    }
    
    private func textInputBinding(for questionTitle: String) -> Binding<String> {
        return Binding(
            get: { self.textInputs[questionTitle] ?? "" },
            set: { self.textInputs[questionTitle] = $0 }
        )
    }
    
    private func numberInputBinding(for questionTitle: String) -> Binding<Double> {
        return Binding(
            get: { self.numberInputs[questionTitle] ?? 0.0 },
            set: { self.numberInputs[questionTitle] = $0 }
        )
    }
    
    private func saveOnboardingData() {
        print("Starting onboarding data save process...")
        
        // Set loading state
        isLoading = true
        
        // Create the onboarding data object
        let onboardingData = UserOnboardingData(
            trainingLevel: selectedOptionsBinding(for: "What is your current level of training?").wrappedValue.first ?? "",
            primaryGoals: Array(selectedOptionsBinding(for: "What are your primary goals?").wrappedValue),
            trainingDaysPerWeek: selectedOptionsBinding(for: "How many days per week can you train?").wrappedValue.first ?? "",
            availableEquipment: Array(selectedOptionsBinding(for: "What equipment do you have access to?").wrappedValue),
            hasInjuries: selectedOptionsBinding(for: "Do you have any injuries or limitations?").wrappedValue.contains("Yes"),
            preferredTrainingStyles: Array(selectedOptionsBinding(for: "Preferred Training Style").wrappedValue),
            preferredTrainingSplit: Array(selectedOptionsBinding(for: "Preferred Training Split").wrappedValue),
            preferredEquipment: Array(selectedOptionsBinding(for: "Preferred Training equipment").wrappedValue)
        )
        
        // Convert to JSON and print
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(onboardingData)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Onboarding Data JSON:")
                print(jsonString)
                
                // Save to a file in the Documents directory
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentsDirectory.appendingPathComponent("onboarding_data.json")
                    try jsonData.write(to: fileURL)
                    print("Saved onboarding data to: \(fileURL.path)")
                    
                    // Show success alert
                    alertMessage = "Onboarding data saved successfully!"
                    showingAlert = true
                }
            }
            
            // Complete the onboarding process
            isLoading = false
            onComplete?()
        } catch {
            print("Error encoding onboarding data: \(error.localizedDescription)")
            isLoading = false
            alertMessage = "Error saving data: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - QuestionView
struct QuestionView: View {
    let question: OnboardingQuestion
    @Binding var selectedOptions: Set<String>
    @Binding var textInput: String
    @Binding var numberInput: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(question.options, id: \.self) { option in
                        OptionButton(
                            option: option,
                            isSelected: selectedOptions.contains(option),
                            allowsMultipleSelection: question.allowsMultipleSelection
                        ) {
                            if question.allowsMultipleSelection {
                                if selectedOptions.contains(option) {
                                    selectedOptions.remove(option)
                                } else {
                                    selectedOptions.insert(option)
                                }
                            } else {
                                selectedOptions = [option]
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - OptionButton
struct OptionButton: View {
    let option: String
    let isSelected: Bool
    let allowsMultipleSelection: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option)
                    .font(.body)
                    .foregroundColor(isSelected ? .white : .primary)
                    .padding(.vertical, 12)
                
                Spacer()
                
                Image(systemName: isSelected 
                      ? (allowsMultipleSelection ? "checkmark.square.fill" : "checkmark.circle.fill") 
                      : (allowsMultipleSelection ? "square" : "circle"))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
        }
    }
}

// MARK: - ProgressBar
struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step \(currentStep) of \(totalSteps)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: geometry.size.width * CGFloat(currentStep) / CGFloat(totalSteps), height: 8)
                        .foregroundColor(.blue)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
        }
    }
}

// MARK: - LoadingView
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Saving...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.7))
            )
        }
    }
} 
