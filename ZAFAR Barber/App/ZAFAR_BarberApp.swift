import SwiftUI
import Firebase

@main
struct ZAFAR_BarberApp: App {
    
    // Bu qator AppDelegate'ni ilovaga bog'laydi
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var themeViewModel = ThemeViewModel()

    // Bu yerdagi init() va FirebaseApp.configure() ni olib tashlaymiz.
    // init() {
    //     FirebaseApp.configure()
    // }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // ThemeViewModel'ni hamma joyda ishlatish uchun
                .environmentObject(themeViewModel)
                // Tanlangan temani butun ilovaga qo'llash
                .preferredColorScheme(themeViewModel.preferredColorScheme)
        }
    }
} 