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
            "Muscle Building",
            "Strength Gain",
            "Weight Loss",
            "General Fitness",
            "Athletic Performance"
        ],
        allowsMultipleSelection: true,
        type: .multipleChoice
    ),
    OnboardingQuestion(
        title: "How many days per week can you train?",
        options: ["2-3", "4-5", "6+"],
        allowsMultipleSelection: false,
        type: .singleChoice
    ),
    OnboardingQuestion(
        title: "What's your preferred workout split?",
        options: [
            "Bro Split (One muscle group per day)",
            "Push Pull Legs (PPL)",
            "Full Body",
            "Upper/Lower Split"
        ],
        allowsMultipleSelection: false,
        type: .singleChoice
    ),
    OnboardingQuestion(
        title: "What equipment do you have access to?",
        options: [
            "Cables",
            "Barbell",
            "Dumbbells",
            "Machines",
            "Resistance Bands",
            "Bodyweight Only"
        ],
        allowsMultipleSelection: true,
        type: .multipleChoice
    ),
    OnboardingQuestion(
        title: "Which areas would you like to focus on?",
        options: [
            "Chest",
            "Back",
            "Shoulders",
            "Arms",
            "Legs",
            "Core",
            "Overall Balance"
        ],
        allowsMultipleSelection: true,
        type: .multipleChoice
    ),
    OnboardingQuestion(
        title: "What's your preferred training intensity?",
        options: [
            "High Intensity (Lower Reps)",
            "Moderate Intensity (Mixed)",
            "Lower Intensity (Higher Reps)"
        ],
        allowsMultipleSelection: false,
        type: .singleChoice
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
            "Bodybuilding",
            "Calisthenics"
        ],
        allowsMultipleSelection: true,
        type: .multipleChoice
    )
] 

// MARK: - QuestionView
struct QuestionView: View {
    let question: OnboardingQuestion
    @Binding var selectedOptions: Set<String>
    @Binding var textInput: String
    @Binding var numberInput: Double
    let currentPage: Int
    let totalPages: Int
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(question.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
            
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
            
            Spacer(minLength: 30)
            
            // Navigation Buttons
            VStack(spacing: 20) {
                Divider()
                    .background(Color.white.opacity(0.3))
                
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: onPrevious) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.purple.opacity(0.3))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            )
                        }
                    }
                    
                    Spacer()
                    
                    if currentPage < totalPages - 1 {
                        Button(action: onNext) {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.3))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            )
                        }
                    } else {
                        Button(action: onComplete) {
                            Text("Get Started")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.green.opacity(0.3))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.black.opacity(0.1))
        }
        .padding(.top)
    }
    
    private func toggleOption(_ option: String) {
        if question.allowsMultipleSelection {
            if question.options.contains(option) {
                selectedOptions.remove(option)
            } else {
                selectedOptions.insert(option)
            }
        } else {
            selectedOptions = [option]
        }
    }
}

var body: some View {
    ZStack {
        // Animated gradient background
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
                .padding(.bottom, 20)
            
            // Question content with TabView
            TabView(selection: $currentPage) {
                ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
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
                                            isSelected: selectedOptionsBinding(for: question.title).wrappedValue.contains(option),
                                            action: {
                                                toggleOption(option, for: question)
                                            }
                                        )
                                    }
                                case .textInput:
                                    OnboardingTextField(
                                        text: textInputBinding(for: question.title),
                                        onSubmit: {}
                                    )
                                case .numberInput:
                                    CustomNumberField(
                                        value: numberInputBinding(for: question.title)
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Navigation indicator
                        if index < questions.count - 1 {
                            HStack {
                                Spacer()
                                Text("Swipe to continue")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.subheadline)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding()
                        } else {
                            Button(action: saveOnboardingData) {
                                Text("Get Started")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green.opacity(0.3))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                    )
                            }
                            .padding()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    .navigationBarHidden(true)
    .alert("Error", isPresented: $showingAlert) {
        Button("OK", role: .cancel) { }
    } message: {
        Text(alertMessage)
    }
}

private func toggleOption(_ option: String, for question: OnboardingQuestion) {
    let binding = selectedOptionsBinding(for: question.title)
    if question.allowsMultipleSelection {
        if binding.wrappedValue.contains(option) {
            binding.wrappedValue.remove(option)
        } else {
            binding.wrappedValue.insert(option)
        }
    } else {
        binding.wrappedValue = [option]
    }
} 