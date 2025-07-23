import SwiftUI

struct BookingView: View {
    // ViewModel'ni tashqaridan qabul qilamiz
    @ObservedObject var viewModel: AppointmentViewModel
    @EnvironmentObject var authViewModel: AuthViewModel // UID ni olish uchun
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var selectedTimeSlot: TimeSlot?

    // Grid uchun ustunlar soni
    private let columns = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Navbat olish")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // 1. Ism va Telefon maydonlari
                VStack {
                    TextField("Ismingiz", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Telefon raqamingiz", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                }
                
                Divider()

                // MUAMMO 1: Kalendarni kichraytirish
                DatePicker(
                    "Kunni tanlang",
                    selection: $viewModel.selectedDate,
                    in: Date()..., // Faqat bugundan boshlab
                    displayedComponents: .date
                )
                .datePickerStyle(CompactDatePickerStyle()) 
                .padding(.horizontal)
                
                Divider()

                // 3. Bo'sh vaqtlarni ko'rsatish
                Text("Bo'sh vaqtlar").font(.title2).fontWeight(.semibold)
                
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(viewModel.timeSlots) { timeSlot in
                        Text(timeSlot.date.formatted(date: .omitted, time: .shortened))
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(slotBackgroundColor(for: timeSlot))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .onTapGesture {
                                if timeSlot.isAvailable {
                                    selectedTimeSlot = timeSlot
                                }
                            }
                    }
                }
                .padding(.horizontal)
                
                // 4. Navbat olish tugmasi
                Button(action: bookAppointment) {
                    Text("Navbatni band qilish")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isBookingButtonDisabled() ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isBookingButtonDisabled())
                .padding()
            }
        }
        .refreshable {
            await viewModel.handleRefresh()
        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
    
    // Funksiyalar
    private func slotBackgroundColor(for timeSlot: TimeSlot) -> Color {
        if !timeSlot.isAvailable {
            return .gray.opacity(0.5)
        }
        if selectedTimeSlot?.id == timeSlot.id {
            return .green
        }
        return .blue
    }
    
    private func isBookingButtonDisabled() -> Bool {
        return name.isEmpty || phone.isEmpty || selectedTimeSlot == nil
    }

    private func bookAppointment() {
        guard let timeSlot = selectedTimeSlot, let uid = authViewModel.appUser?.uid else { return }
        viewModel.addAppointment(for: timeSlot, name: name, phone: phone, uid: uid)
        
        // Formani tozalash
        name = ""
        phone = ""
        selectedTimeSlot = nil
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview endi oddiy ViewModel'ni qabul qiladi
        BookingView(viewModel: AppointmentViewModel())
            .environmentObject(AuthViewModel())
    }
} 
