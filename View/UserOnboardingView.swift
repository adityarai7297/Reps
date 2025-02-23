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
            "Core"
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
        
        VStack(spacing: 20) {
            // Progress bar
            ProgressBar(currentStep: currentPage + 1, totalSteps: questions.count)
                .padding(.top, 60)
                .padding(.horizontal)
            
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
            .animation(.easeInOut, value: currentPage)
            .disabled(true) // Disable swipe gesture
            
            // Bottom Navigation Buttons
            HStack(spacing: 20) {
                if currentPage > 0 {
                    Button(action: {
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
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
                
                Spacer()
                
                if currentPage < questions.count - 1 {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
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
                                .fill(.ultraThinMaterial)
                        )
                    }
                } else {
                    Button(action: {
                        saveOnboardingData()
                    }) {
                        Text("Get Started")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    .navigationBarHidden(true)
    .alert("Error", isPresented: $showingAlert) {
        Button("OK", role: .cancel) { }
    } message: {
        Text(alertMessage)
    }
} 