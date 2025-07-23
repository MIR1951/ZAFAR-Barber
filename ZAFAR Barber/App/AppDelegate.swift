import UIKit
import Firebase
import FirebaseAuth

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        // Push-xabarnomalar uchun ruxsat so'rash
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()
        
        return true
    }

    // Qurilma tokeni muvaffaqiyatli olinganda
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅ APNs device token received: \(deviceToken)")
        // Tokenni Firebase'ga yuborish
        Auth.auth().setAPNSToken(deviceToken, type: .prod) // .prod - App Store uchun, .sandbox - test uchun
    }
    
    // Qurilma tokenini olishda xatolik
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("🔴 Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // Yashirin push-xabarni Firebase'ga uzatish
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Silent push notification received.")
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        
        completionHandler(.newData)
    }
}

// Push-xabarlarni ilova ochiq paytda ham ko'rsatish uchun
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
} 