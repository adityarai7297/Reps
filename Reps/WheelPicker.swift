//
//  WheelPicker.swift
//  HorizontalWheelPicker
//
//  Created by Balaji Venkatesh on 15/03/24.
//

import SwiftUI

struct WheelPicker: View {
    /// Config
    var config: Config
    @Binding var value: CGFloat
    /// View Properties
    @State private var isLoaded: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let horizontalPadding = size.width / 2
            
            ScrollView(.horizontal) {
                HStack(spacing: config.spacing) {
                    let totalSteps = config.steps * config.count
                    
                    ForEach(0...totalSteps, id: \.self) { _ in
                        Color.clear // Invisible element to maintain structure
                            .frame(width: config.spacing, height: 20)
                    }
                }
                .frame(height: size.height)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: .init(get: {
                let position: Int? = isLoaded ? Int(value * CGFloat(config.steps * 2) / CGFloat(config.multiplier)) : nil
                return position
            }, set: { newValue in
                if let newValue {
                    value = (CGFloat(newValue) / CGFloat(config.steps * 2)) * CGFloat(config.multiplier)
                }
            }))
            .safeAreaPadding(.horizontal, horizontalPadding)
            .onAppear {
                if !isLoaded { isLoaded = true }
            }
        }
        .onChange(of: config) { _, _ in
            value = 0
        }
    }
    
    /// Picker Configuration
    struct Config: Equatable {
        var count: Int
        var steps: Int = 10
        var spacing: CGFloat = 5
        var multiplier: Int = 1
    }
}

#Preview {
    ContentView()
}
