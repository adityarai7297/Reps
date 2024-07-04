import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack {
            // Add a cute image here if desired
            Text("Start adding exercises!")
                .font(.title)
                .padding()
        }
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView()
    }
}
