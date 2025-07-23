import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 1. Profil qismi
            profileSection
            
            Divider()
            
            // 2. Menyu bo'limlari
            menuItem(icon: "person.fill", text: "Profilim")
            menuItem(icon: "calendar", text: "Mening Bandliklarim")
            menuItem(icon: "bell.fill", text: "Notifikatsiyalar")
            
            Spacer()
            
            // 3. Chiqish bo'limi
            logoutSection
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.theme.background)
    }
}


// MARK: - View Components
private extension SideMenuView {
    var profileSection: some View {
        VStack(alignment: .leading) {
            Image("barber-photo")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            
            Text(authViewModel.appUser?.phoneNumber ?? "Foydalanuvchi")
                .font(.title2.bold())
                .foregroundColor(.theme.primaryText)
            
            Text("Profilni ko'rish")
                .font(.subheadline)
                .foregroundColor(.theme.secondaryText)
        }
    }
    
    func menuItem(icon: String, text: String) -> some View {
        Button {
            // Kerakli sahifaga o'tish logikasi
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.headline)
                    .frame(width: 24)
                Text(text)
                    .font(.headline)
            }
            .foregroundColor(.theme.primaryText)
        }
    }
    
    var logoutSection: some View {
        Button {
            authViewModel.signOut()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "arrow.left.square.fill")
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(width: 24)
                Text("Chiqish")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Preview
struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeViewModel())
    }
} 