import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Shaxsiy ma'lumotlar")) {
                    if let user = authViewModel.appUser {
                        Text("Ism: \(user.id ?? "N/A")") // Hozircha ism yo'q, ID ni ko'rsatamiz
                        Text("Telefon: \(user.phoneNumber)")
                    } else {
                        Text("Ma'lumotlar yuklanmoqda...")
                    }
                    Button("Ma'lumotlarni tahrirlash") {
                        // Kelajakda bu yerda tahrirlash ekrani ochiladi
                    }
                }
                
                Section(header: Text("Sozlamalar")) {
                    Picker("Ilova mavzusi", selection: $themeViewModel.themeSetting) {
                        Text("Tizim").tag(0)
                        Text("Yorug'").tag(1)
                        Text("Qorong'u").tag(2)
                    }
                }
                
                Section {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Chiqish")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profil")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeViewModel())
    }
} 