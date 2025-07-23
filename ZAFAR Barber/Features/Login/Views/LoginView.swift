import SwiftUI

struct LoginView: View {
    // @StateObject o'rniga @ObservedObject ishlatamiz. 
    // Bu "ViewModel menga tashqaridan keladi" degani.
    @ObservedObject var authViewModel: AuthViewModel
    
    @State private var phoneNumber: String = "+998"
    @State private var verificationCode: String = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Tizimga kirish")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if authViewModel.verificationID == nil {
                    phoneInputView
                } else {
                    verificationInputView
                }
                
                Spacer()
            }
            .padding()
            .onTapGesture {
                self.hideKeyboard()
            }
            // Xato xabari bo'lsa, uni alert orqali ko'rsatamiz
            .alert(item: $authViewModel.errorMessage) { error in
                Alert(title: Text("Xatolik"), message: Text(error), dismissButton: .default(Text("OK")))
            }
            
            // isLoading indikatori uchun
            if authViewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                ProgressView("Tekshirilmoqda...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    private var phoneInputView: some View {
        VStack(spacing: 20) {
            Text("Iltimos, telefon raqamingizni kiriting.")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            TextField("Telefon raqam", text: $phoneNumber)
                .keyboardType(.phonePad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                authViewModel.sendVerificationCode(phoneNumber: phoneNumber)
            }) {
                Text("Kod yuborish")
                    .modifier(PrimaryButtonModifier())
            }
        }
    }
    
    private var verificationInputView: some View {
        VStack(spacing: 20) {
            Text("SMS-kodni kiriting.")
                .font(.headline)

            TextField("Tasdiqlash kodi", text: $verificationCode)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                authViewModel.signInWithVerificationCode(verificationCode: verificationCode)
            }) {
                Text("Tizimga kirish")
                    .modifier(PrimaryButtonModifier())
            }
        }
    }
}

// String ni Alert bilan ishlatish uchun kengaytma
extension String: Identifiable {
    public var id: String {
        self
    }
}

// Bu yerdagi View kengaytmasini olib tashlaymiz
// #if canImport(UIKit)
// extension View {
//     func hideKeyboard() {
//         UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//     }
// }
// #endif

// A simple modifier for consistent button styling
struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview uchun AuthViewModel yaratib beramiz
        LoginView(authViewModel: AuthViewModel())
    }
} 