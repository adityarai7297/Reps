//
//  ContentView.swift
//  Reps
//
//  Created by Rai, Adi on 6/22/24.
//

import SwiftUI

struct ContentView: View {
    @State private var number: Int = 0

    var body: some View {
        VStack {
            Spacer()
            Text("\(number)")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let dragAmount = value.translation.height
                    let increment = Int(dragAmount / 10) // Adjust the divisor to control sensitivity
                    if increment != 0 {
                        number -= increment
                    }
                }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
