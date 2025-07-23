import SwiftUI

class ThemeViewModel: ObservableObject {
    @AppStorage("selectedTheme") var themeSetting: Int = 0 // 0: System, 1: Light, 2: Dark

    var preferredColorScheme: ColorScheme? {
        if themeSetting == 1 {
            return .light
        } else if themeSetting == 2 {
            return .dark
        }
        return nil // System default
    }
} 