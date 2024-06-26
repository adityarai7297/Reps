import Foundation
import SwiftUI

struct SetButton: View {
     @State var Hpress = false
     @State var fb = false
     @GestureState var topG = false
    var body: some View {
        ZStack {
            Color("BG")
            ZStack{
                Circle().frame(width: 120, height: 120)
                    .foregroundColor(Color("BG"))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 10, y: 10)
                    .shadow(color: .white.opacity(0.6), radius: 10, x: -20, y: -20)
                Circle()
                    .stroke(lineWidth: 7)
                    .frame(width: 120, height: 120)
                    .foregroundColor(Color("BG"))
                Circle()
                    .stroke(lineWidth: 5.5)
                    .frame(width: 105, height: 105)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.black.opacity(0.06),.gray.opacity(0.01),.black.opacity(0.06)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                
                if topG{
                    Circle()
                        .stroke(lineWidth: 15)
                        .frame(width: 105, height: 105)
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.black.opacity(0.1),.white ]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .blur(radius: 3)
                    
                }
                ZStack{
                    Image("FP")
                        .scaleEffect(Hpress ? 0 : 1)
                    Image("FP2")
                        .scaleEffect(Hpress ? 0 : 1)
                        .clipShape(Circle().offset(y: topG ? 0 : 120))
                        .animation(.easeInOut.speed(0.3), value: topG)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .scaleEffect(Hpress ? 1 : 0)
                        .animation(.easeInOut, value: Hpress)
                    
                    
                    
                }
           
 
            }
            .overlay(content: {
                Circle().trim(from: 0, to:topG ? 1: 0)
                    .stroke(style: StrokeStyle(lineWidth: 7,lineCap: .round))
                    .rotation(.degrees(-90))
            })
            .animation(.easeInOut.speed(0.5), value:topG)
            .scaleEffect(topG ? 1.2 : 1)
            .gesture(LongPressGesture(minimumDuration: 1.5, maximumDistance: 1).updating($topG){ cstate ,gstate , trantion in
                gstate = cstate
            }
                .onEnded({ value in
                    Hpress.toggle()
                })
            )
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: topG)
            
           
        }
        .ignoresSafeArea()
    }
}

