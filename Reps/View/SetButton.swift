import SwiftUI

struct SetButton: View {
    @State var fb = false
    @GestureState var topG = false
    @State var showCheckmark = false

    var body: some View {
        ZStack {
            
            VStack {
                if showCheckmark {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.green)
                            .frame(width: 150, height: 50)
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                            
                            Text("Added!")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    }
                    .transition(.scale)
                    .opacity(showCheckmark ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCheckmark)
                }
                
                Spacer().frame(height: 20) // Add padding between the checkmark and button
                
                ZStack {
                    
                    Circle()
                        .stroke(lineWidth: 0.2)
                        .frame(width: 92, height: 92)
                    
                    Text("SET")
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .overlay(content: {
                    Circle().trim(from: 0, to: topG ? 1 : 0)
                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotation(.degrees(-90))
                })
                .animation(.easeInOut.speed(0.8), value: topG)
                .scaleEffect(topG ? 1.1 : 1)
                .gesture(LongPressGesture(minimumDuration: 0.4, maximumDistance: 1).updating($topG) { cstate, gstate, transition in
                    gstate = cstate
                }
                    .onEnded({ value in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            showCheckmark = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                showCheckmark = false
                            }
                        }
                    })
                )
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: topG)
            }
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
