import SwiftUI

// Yangi dizayn uchun ranglar palitrasi
extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // #F6F6F6 - Och kulrang fon
    let background = Color(hex: "F6F6F6")
    // #1E1E1E - To'q kulrang matn
    let primaryText = Color(hex: "1E1E1E")
    // #8A8A8E - Ikkilamchi kulrang matn
    let secondaryText = Color(hex: "8A8A8E")
    // #2C2C2E - Urg'u rangi (tugmalar, tanlangan elementlar)
    let accent = Color(hex: "2C2C2E")
}


// Hex rang kodidan SwiftUI Color yaratish uchun yordamchi
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 