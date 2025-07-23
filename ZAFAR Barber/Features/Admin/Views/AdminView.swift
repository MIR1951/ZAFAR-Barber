import SwiftUI

struct AdminView: View {
    // ViewModel'ni o'zi yaratmaydi, Environment'dan oladi
    @EnvironmentObject var viewModel: AppointmentViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Kunni tanlang",
                    selection: $viewModel.selectedDate,
                    displayedComponents: .date
                )
                .padding()
                .datePickerStyle(CompactDatePickerStyle())

                // List endi refreshable bo'ldi
                List {
                    // Yordamchi funksiya o'rniga mantiqni shu yerga ko'chiramiz
                    ForEach(viewModel.timeSlots) { timeSlot in
                        if let appointment = viewModel.appointments.first(where: { $0.appointmentTime == timeSlot.date }) {
                            // Agar vaqt band bo'lsa
                            appointmentRow(for: appointment)
                        } else {
                            // Agar vaqt bo'sh bo'lsa
                            HStack {
                                Text(timeSlot.date.formatted(date: .omitted, time: .shortened))
                                    .fontWeight(.bold)
                                Spacer()
                                Text("Bo'sh")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .refreshable {
                    // Tortganda shu funksiya chaqiriladi
                    await viewModel.handleRefresh()
                }
            }
            .navigationTitle("Kunlik Jadval")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiqish") {
                        authViewModel.signOut()
                    }
                }
            }
        }
    }
    
    // timeSlotRow funksiyasi endi kerak emas, uni olib tashlaymiz

    // Band bo'lgan navbat uchun qator
    private func appointmentRow(for appointment: Appointment) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(appointment.appointmentTime.formatted(date: .omitted, time: .shortened))
                    .fontWeight(.bold)
                Text(appointment.name).font(.headline)
                Text(appointment.phone).font(.subheadline).foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(appointment.status.rawValue)
                    .font(.headline)
                    .foregroundColor(statusColor(for: appointment.status))
                
                if appointment.status == .pending {
                    HStack {
                        Button("Tasdiqlash") {
                            viewModel.updateAppointmentStatus(appointmentId: appointment.id!, newStatus: .approved)
                        }
                        .tint(.green)
                        
                        Button("Rad qilish") {
                            viewModel.updateAppointmentStatus(appointmentId: appointment.id!, newStatus: .rejected)
                        }
                        .tint(.red)
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 5)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func statusColor(for status: AppointmentStatus) -> Color {
        switch status {
        case .approved: return .green
        case .rejected: return .red
        case .pending: return .orange
        }
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
            .environmentObject(AppointmentViewModel()) // Preview uchun
            .environmentObject(AuthViewModel())
    }
} 
