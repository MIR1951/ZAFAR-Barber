import SwiftUI

struct BookingView: View {
    @StateObject private var viewModel = AppointmentViewModel()
    @Environment(\.dismiss) var dismiss // Oynani yopish uchun
    
    // Tanlangan kun va vaqt uchun
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: Date?

    var body: some View {
        VStack(spacing: 0) {
            // Modal oyna sarlavhasi
            header
            
            // Kunlarni tanlash (gorizontal scroll)
            dateScrollView
            
            // Vaqtlarni tanlash (grid)
            timeSlotsGrid
            
            // Tugma
            bookNowButton
        }
        .background(Color.theme.background)
        .onAppear {
            // ViewModel'ga hozirgi tanlangan kunni aytamiz
            viewModel.selectedDate = selectedDate
        }
        .onChange(of: selectedDate) { newDate in
            // Kun o'zgarganda ViewModel'ni yangilaymiz
            viewModel.selectedDate = newDate
            selectedTimeSlot = nil // Eski tanlovni bekor qilish
        }
    }
}


// MARK: - View Components
private extension BookingView {
    var header: some View {
        HStack {
            Text("Vaqtni belgilash")
                .font(.title2.bold())
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    var dateScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Kelasi 7 kunni ko'rsatamiz
                ForEach(0..<7) { i in
                    dateCell(for: i)
                }
            }
            .padding(.horizontal)
        }
    }
    
    func dateCell(for index: Int) -> some View {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: index, to: Date())!
        let isSelected = calendar.isDate(selectedDate, inSameDayAs: date)
        
        // DateFormatter yordamida formatlash
        let weekdayFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "E" // "Ses", "Chor", "Pay"
            return formatter
        }()
        
        let dayFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "d" // "15", "16", "17"
            return formatter
        }()
        
        return VStack {
            Text(weekdayFormatter.string(from: date))
                .font(.headline)
            Text(dayFormatter.string(from: date))
                .fontWeight(.bold)
        }
        .padding()
        .frame(width: 80, height: 80)
        // Orqa fonni oq qilamiz, tanlanganda esa accent
        .background(isSelected ? Color.theme.accent : Color.white)
        .foregroundColor(isSelected ? .white : Color.theme.primaryText)
        .cornerRadius(15)
        .shadow(color: isSelected ? Color.theme.accent.opacity(0.4) : .black.opacity(0.1), radius: 5)
        .onTapGesture {
            selectedDate = date
        }
    }
    
    var timeSlotsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(viewModel.timeSlots.filter { $0.isAvailable }) { timeSlot in
                    timeSlotCell(for: timeSlot)
                }
            }
            .padding()
        }
    }
    
    func timeSlotCell(for timeSlot: TimeSlot) -> some View {
        let isSelected = selectedTimeSlot == timeSlot.date
        return Text(timeSlot.date.formatted(date: .omitted, time: .shortened))
            .fontWeight(.bold)
            .padding()
            .frame(maxWidth: .infinity)
            // Tanlanmagan vaqt foni endi oq
            .background(isSelected ? Color.theme.accent : Color.white)
            .foregroundColor(isSelected ? .white : .theme.primaryText)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .onTapGesture {
                selectedTimeSlot = timeSlot.date
            }
    }
    
    var bookNowButton: some View {
        Button {
            // Navbat olish logikasi
            // Bu yerda ism va telefon kiritish oynasi chiqishi kerak
            // Hozircha shunchaki yopamiz
            dismiss()
        } label: {
            // Bu yerni ham to'g'rilash kerak
            let buttonText = selectedTimeSlot == nil ? "Vaqtni tanlang" : "\(selectedDate.formatted(date: .abbreviated, time: .omitted)), \(selectedTimeSlot!.formatted(date: .omitted, time: .shortened)) - Band qilish"
            Text(buttonText)
                .font(.headline.bold())
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.theme.accent)
                .cornerRadius(15)
        }
        .padding()
        .disabled(selectedTimeSlot == nil)
    }
}


// MARK: - Preview
struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView()
            .environmentObject(ThemeViewModel())
    }
} 
