import SwiftUI

struct MyBookingsView: View {
    @ObservedObject var viewModel: AppointmentViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        // Faqat shu foydalanuvchiga tegishli navbatlarni filtrlash
        let userAppointments = viewModel.appointments.filter {
            $0.userId == authViewModel.appUser?.uid
        }.sorted(by: { $0.appointmentTime > $1.appointmentTime }) // Eng yangilari tepada
        
        ZStack {
            // Orqa fon
            Color.theme.background.ignoresSafeArea()
            
            // Asosiy kontent
            ScrollView {
                if userAppointments.isEmpty {
                    emptyStateView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(userAppointments) { appointment in
                            appointmentCard(for: appointment)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Mening Navbatlarim")
    }
    
    // Bo'sh holat uchun View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(Color.theme.secondaryText)
            Text("Sizda hali navbatlar yo'q")
                .font(.title2.bold())
                .foregroundColor(Color.theme.primaryText)
            Text("Asosiy sahifadan o'zingizga qulay vaqtni band qilishingiz mumkin.")
                .font(.subheadline)
                .foregroundColor(Color.theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
        .padding()
    }
    
    // Har bir navbat uchun kartochka
    private func appointmentCard(for appointment: Appointment) -> some View {
        HStack(spacing: 0) {
            // Status rangini ko'rsatuvchi chiziq
            Rectangle()
                .fill(statusColor(for: appointment.status))
                .frame(width: 8)
            
            // Asosiy ma'lumotlar
            VStack(alignment: .leading, spacing: 8) {
                Text(appointment.appointmentTime, style: .date)
                    .font(.headline).bold()
                    .foregroundColor(Color.theme.primaryText)
                
                HStack {
                    Text(appointment.appointmentTime, style: .time)
                        .font(.title2).bold()
                    Spacer()
                    Text(appointment.status.rawValue)
                        .font(.headline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor(for: appointment.status).opacity(0.15))
                        .foregroundColor(statusColor(for: appointment.status))
                        .cornerRadius(20)
                }
            }
            .padding()
        }
        .background(Color.theme.background)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    private func statusColor(for status: AppointmentStatus) -> Color {
        switch status {
        case .approved: return .green
        case .rejected: return .red
        case .pending: return .orange
        }
    }
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
}()


struct MyBookingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyBookingsView(viewModel: AppointmentViewModel())
                .environmentObject(AuthViewModel())
                .environmentObject(ThemeViewModel())
        }
    }
} 