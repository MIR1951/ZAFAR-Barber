import SwiftUI
import Firebase

@main
struct ZAFAR_BarberApp: App {
    
    // Bu qator AppDelegate'ni ilovaga bog'laydi
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // Bu yerdagi init() va FirebaseApp.configure() ni olib tashlaymiz.
    // init() {
    //     FirebaseApp.configure()
    // }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
} 