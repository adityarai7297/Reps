import SwiftUI
import SwiftData

// MARK: - Models
struct OnboardingQuestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let options: [String]
    let allowsMultipleSelection: Bool
    let type: QuestionType
    
    enum QuestionType {
        case singleChoice
        case multipleChoice
        case numberInput
        case textInput
    }
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
    var onComplete: (() -> Void)?
    
    // Define all onboarding questions
    let questions: [OnboardingQuestion] = [
        OnboardingQuestion(
            title: "What is your current level of training?",
            options: ["Beginner", "Intermediate", "Advanced"],
            allowsMultipleSelection: false,
            type: .singleChoice
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
            type: .multipleChoice
        ),
        OnboardingQuestion(
            title: "How many days per week can you train?",
            options: ["1-2", "3-4", "5+"],
            allowsMultipleSelection: false,
            type: .singleChoice
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
            type: .multipleChoice
        ),
        OnboardingQuestion(
            title: "Do you have any injuries or limitations?",
            options: ["Yes", "No"],
            allowsMultipleSelection: false,
            type: .singleChoice
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
            type: .multipleChoice
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
                
                // Navigation Buttons
                HStack {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    Spacer()
                    if currentPage < questions.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    } else {
                        Button(action: {
                            // Save onboarding data and dismiss
                            saveOnboardingData()
                        }) {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                )
                        }
                    }
                }
                .padding()
                
                // Question content
                TabView(selection: $currentPage) {
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        QuestionView(
                            question: question,
                            selectedOptions: selectedOptionsBinding(for: question.title),
                            textInput: textInputBinding(for: question.title),
                            numberInput: numberInputBinding(for: question.title)
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func selectedOptionsBinding(for questionTitle: String) -> Binding<Set<String>> {
        Binding(
            get: { selectedOptions[questionTitle] ?? Set() },
            set: { selectedOptions[questionTitle] = $0 }
        )
    }
    
    private func textInputBinding(for questionTitle: String) -> Binding<String> {
        Binding(
            get: { textInputs[questionTitle] ?? "" },
            set: { textInputs[questionTitle] = $0 }
        )
    }
    
    private func numberInputBinding(for questionTitle: String) -> Binding<Double> {
        Binding(
            get: { numberInputs[questionTitle] ?? 0.0 },
            set: { numberInputs[questionTitle] = $0 }
        )
    }
    
    private func saveOnboardingData() {
        // Validate required fields
        guard let trainingLevel = selectedOptions["What is your current level of training?"]?.first,
              !trainingLevel.isEmpty else {
            showingAlert = true
            alertMessage = "Please select your training level"
            return
        }
        
        // Create and save user onboarding data
        let onboardingData = UserOnboardingData()
        onboardingData.update(with: selectedOptions)
        
        modelContext.insert(onboardingData)
        
        do {
            try modelContext.save()
            onComplete?()  // Call completion handler if provided
            presentationMode.wrappedValue.dismiss()
        } catch {
            showingAlert = true
            alertMessage = "Failed to save onboarding data: \(error.localizedDescription)"
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
        VStack(alignment: .leading, spacing: 24) {
            Text(question.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    switch question.type {
                    case .singleChoice, .multipleChoice:
                        ForEach(question.options, id: \.self) { option in
                            OptionButton(
                                title: option,
                                isSelected: selectedOptions.contains(option),
                                action: {
                                    toggleOption(option)
                                }
                            )
                        }
                    case .textInput:
                        OnboardingTextField(text: $textInput, onSubmit: {
                            // Handle text submission if needed
                        })
                    case .numberInput:
                        CustomNumberField(value: $numberInput)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    private func toggleOption(_ option: String) {
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

// MARK: - Supporting Views
struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * CGFloat(currentStep) / CGFloat(totalSteps), height: 4)
                    .cornerRadius(2)
            }
        }
        .frame(height: 4)
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

struct OnboardingTextField: View {
    @Binding var text: String
    let onSubmit: () -> Void
    
    var body: some View {
        TextField("Enter your answer", text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .onSubmit(onSubmit)
    }
}

struct CustomNumberField: View {
    @Binding var value: Double
    
    var body: some View {
        TextField("Enter a number", value: $value, format: .number)
            .keyboardType(.numberPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
    }
}

// MARK: - Preview
struct UserOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        UserOnboardingView()
    }
} 
