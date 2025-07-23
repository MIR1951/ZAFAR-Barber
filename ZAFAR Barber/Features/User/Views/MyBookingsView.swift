import SwiftUI

struct MyBookingsView: View {
    // ViewModelni tashqaridan qabul qilamiz
    @ObservedObject var viewModel: AppointmentViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        // Faqat shu foydalanuvchiga tegishli navbatlarni filtrlash
        let userAppointments = viewModel.appointments.filter {
            $0.userId == authViewModel.appUser?.uid
        }
        
        List {
            if userAppointments.isEmpty {
                Text("Sizda hali navbatlar yo'q.")
                    .foregroundColor(.gray)
            } else {
                ForEach(userAppointments) { appointment in
                    VStack(alignment: .leading) {
                        Text("Vaqt: \(appointment.appointmentTime, formatter: itemFormatter)")
                            .font(.headline)
                        
                        HStack {
                           Text("Holati:")
                           Text(appointment.status.rawValue)
                                .fontWeight(.bold)
                                .foregroundColor(statusColor(for: appointment.status))
                        }
                        .font(.subheadline)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Mening navbatlarim")
        // .onAppear da fetch chaqirish shart emas, chunki ViewModel o'zi boshqaradi
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
        }
    }
} 
