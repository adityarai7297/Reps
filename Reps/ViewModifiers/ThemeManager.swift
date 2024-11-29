import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    var backgroundColor: Color {
        isDarkMode ? .black : .white
    }
    
    var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7)
    }
    
    var separatorColor: Color {
        isDarkMode ? .white.opacity(0.2) : .black.opacity(0.2)
    }
    
    var wheelPickerColor: Color {
        isDarkMode ? .white : .black
    }
    
    var navigationIconColor: Color {
        isDarkMode ? .white : .black
    }
} 
