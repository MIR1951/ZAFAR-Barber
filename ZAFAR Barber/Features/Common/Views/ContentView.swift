import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    // AppointmentViewModel'ni alohida yaratamiz
    @StateObject private var appointmentViewModel = AppointmentViewModel()

    // init() endi kerak emas, chunki ViewModel'lar bog'liq emas
    
    var body: some View {
        // Asosiy switch. Mantiq soddalashtirildi.
        switch authViewModel.authState {
        case .loading:
            ProgressView()
        case .loggedOut:
            LoginView(authViewModel: authViewModel)
        case .loggedIn:
            // Murakkab mantiqni alohida view builderga chiqaramiz
            loggedInView
        }
    }
    
    // @ViewBuilder yordamida logindan o'tgan foydalanuvchi uchun View quruvchi
    @ViewBuilder
    private var loggedInView: some View {
        if let user = authViewModel.appUser {
            // Rolga qarab kerakli View'ni tanlaymiz
            if user.role == "admin" {
                AdminView()
                    .environmentObject(appointmentViewModel)
                    .environmentObject(authViewModel)
                    .onAppear {
                        appointmentViewModel.fetchAppointments(for: Date())
                    }
                    .onDisappear {
                        appointmentViewModel.clearData()
                    }
            } else {
                UserTabs()
                    .environmentObject(appointmentViewModel)
                    .environmentObject(authViewModel)
                    .onAppear {
                        appointmentViewModel.fetchAppointments(for: Date())
                    }
                    .onDisappear {
                        appointmentViewModel.clearData()
                    }
            }
        } else {
            // Foydalanuvchi ma'lumotlari yuklanayotgan paytda ko'rinadi
            ProgressView()
        }
    }
}

struct UserTabs: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appointmentViewModel: AppointmentViewModel
    
    var body: some View {
        NavigationView {
            TabView {
                BookingView(viewModel: appointmentViewModel)
                    .tabItem {
                        Label("Navbat Olish", systemImage: "calendar.badge.plus")
                    }
                
                MyBookingsView(viewModel: appointmentViewModel)
                    .tabItem {
                        Label("Mening Navbatlarim", systemImage: "list.bullet")
                    }
            }
            .navigationTitle("Sartaroshxona")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiqish") {
                        authViewModel.signOut()
                    }
                }
            }
        }
    }
}

// AppUser'ni Equatable qilish
extension AppUser: Equatable {
    static func == (lhs: AppUser, rhs: AppUser) -> Bool {
        lhs.uid == rhs.uid
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 
