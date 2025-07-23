import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var appUser: AppUser?
    @Published var verificationID: String?
    
    // State Management
    @Published var isLoading = false
    @Published var authState: AuthState = .loading
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private var db = Firestore.firestore()
    private var auth = Auth.auth()
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    enum AuthState {
        case loading, loggedIn, loggedOut
    }
    
    // MARK: - Lifecycle
    init() {
        print("AuthViewModel Initialized")
        self.listenToAuthState()
    }
    
    deinit {
        if let handle = self.authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            print("AuthViewModel Deinitialized. Listener removed.")
        }
    }

    // MARK: - Authentication Flow
    func listenToAuthState() {
        self.authStateHandle = auth.addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }
            print("Auth state changed. User: \(user?.uid ?? "nil")")
            DispatchQueue.main.async {
                self.isLoading = false
                if let user = user {
                    self.fetchUser(uid: user.uid)
                } else {
                    self.appUser = nil
                    self.authState = .loggedOut
                }
            }
        }
    }

    func sendVerificationCode(phoneNumber: String) {
        print("1. Attempting to send verification code to: \(phoneNumber)")
        isLoading = true
        errorMessage = nil
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] (verificationID, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("🔴 ERROR sending code: \(error.localizedDescription)")
                    self.errorMessage = "Kod yuborishda xato: \(error.localizedDescription)"
                    return
                }
                if let id = verificationID {
                    print("✅ SUCCESS: Received verificationID: \(id)")
                    self.verificationID = id
                } else {
                     print("🔴 ERROR: VerificationID is nil, but no error was thrown.")
                     self.errorMessage = "Noma'lum xato: verificationID bo'sh keldi."
                }
            }
        }
    }

    func signInWithVerificationCode(verificationCode: String) {
        guard let verificationID = self.verificationID else {
            self.errorMessage = "Xatolik: Jarayon eskirgan. Iltimos, boshidan boshlang."
            print("🔴 ERROR: signIn tapped but verificationID is nil.")
            return
        }
        
        print("2. Attempting to sign in with verificationID: \(verificationID) and code: \(verificationCode)")
        isLoading = true
        errorMessage = nil
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)

        auth.signIn(with: credential) { [weak self] (authResult, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // isLoading = false ni listenToAuthState o'zi boshqaradi.
                if let error = error {
                    print("🔴 ERROR signing in: \(error.localizedDescription)")
                    self.errorMessage = "Tizimga kirishda xato: Kod noto'g'ri yoki jarayon eskirdi."
                    self.verificationID = nil // Jarayonni boshiga qaytarish
                    self.isLoading = false
                    return
                }
                print("✅ SUCCESS: Sign-in successful. Waiting for auth state change.")
                // Muvaffaqiyatli kirsa, listenToAuthState o'zi ishlab ketadi.
            }
        }
    }
    
    func signOut() {
        print("Attempting to sign out.")
        // verificationID ni tozalash
        self.verificationID = nil
        try? auth.signOut()
    }

    // MARK: - Database Operations
    private func fetchUser(uid: String) {
        print("3. Fetching user from Firestore with UID: \(uid)")
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { (querySnapshot, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("🔴 ERROR fetching user: \(error.localizedDescription)")
                    self.errorMessage = "Foydalanuvchi ma'lumotlarini olib bo'lmadi."
                    self.authState = .loggedOut
                    return
                }

                if let document = querySnapshot?.documents.first, let user = try? document.data(as: AppUser.self) {
                    print("✅ SUCCESS: User found in Firestore. Role: \(user.role)")
                    self.appUser = user
                    self.authState = .loggedIn
                } else {
                    print("User not found in Firestore, creating new entry.")
                    self.createUserInDB(uid: uid, phoneNumber: self.auth.currentUser?.phoneNumber ?? "N/A")
                }
            }
        }
    }
    
    private func createUserInDB(uid: String, phoneNumber: String) {
        print("4. Creating new user in Firestore with UID: \(uid)")
        let newUser = AppUser(uid: uid, phoneNumber: phoneNumber)
        do {
            _ = try db.collection("users").addDocument(from: newUser) { [weak self] error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let error = error {
                        print("🔴 ERROR creating user in DB: \(error.localizedDescription)")
                        self.errorMessage = "Yangi foydalanuvchini saqlashda xato."
                        self.authState = .loggedOut
                    } else {
                        print("✅ SUCCESS: New user created and saved.")
                        self.appUser = newUser
                        self.authState = .loggedIn
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "DB xatosi: \(error.localizedDescription)"
                self.authState = .loggedOut
            }
        }
    }
} 
    

