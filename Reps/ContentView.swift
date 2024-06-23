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
        Text("\(number)")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.height < 0 {
                            // Swipe up
                            number += 1
                        } else if value.translation.height > 0 {
                            // Swipe down
                            number -= 1
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

