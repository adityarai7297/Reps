import SwiftUI

struct WorkoutPlanOnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0

    // Define onboarding pages and their titles
    let pages = ["Select workout type", "Choose intensity", "Set workout days"]

    var body: some View {
        VStack {
            // Navigation Buttons
            HStack {
                if currentPage > 0 {
                    Button(action: {
                        withAnimation {
                            currentPage -= 1
                        }
                    }) {
                        Text("Back")
                    }
                }
                Spacer()
                if currentPage < pages.count - 1 {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("Next")
                    }
                } else {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Finish")
                    }
                }
            }
            .padding()

            // Onboarding Content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \ .self) { index in
                    VStack(spacing: 20) {
                        Text(pages[index])
                            .font(.title)
                            .padding(.top)
                        // Multiple choices list
                        List(getOptions(for: index), id: \ .self) { option in
                            Button(action: {
                                // Handle selection of an option
                                // In a full implementation, you could store this
                            }) {
                                Text(option)
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        }
        .navigationBarHidden(true)
    }

    // Returns option choices for each onboarding page
    func getOptions(for index: Int) -> [String] {
        switch index {
        case 0:
            return ["Strength", "Cardio", "Flexibility"]
        case 1:
            return ["Low", "Medium", "High"]
        case 2:
            return ["Monday & Thursday", "Tuesday & Friday", "Wednesday & Saturday"]
        default:
            return []
        }
    }
}

struct WorkoutPlanOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutPlanOnboardingView()
    }
} 