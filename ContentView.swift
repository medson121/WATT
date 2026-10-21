import SwiftUI

struct ContentView: View {
    @State private var hasStartedQuiz = false

    var body: some View {
        if hasStartedQuiz {
            QuizView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
        } else {
            OnboardingView(onFindVampires: {
                withAnimation(.easeInOut(duration: 0.35)) {
                    hasStartedQuiz = true
                }
            })
            .transition(.opacity)
        }
    }
}

#Preview {
    ContentView()
}
