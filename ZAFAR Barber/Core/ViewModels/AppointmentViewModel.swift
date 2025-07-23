import Foundation
import Firebase
import FirebaseFirestore
import Combine

class AppointmentViewModel: ObservableObject {
    @Published var appointments = [Appointment]()
    @Published var timeSlots = [TimeSlot]()
    @Published var selectedDate = Date()
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private var listenerRegistration: ListenerRegistration?

    init() {
        setupSubscribers()
        // ViewModel ishga tushishi bilan bugungi kun uchun ma'lumotlarni yuklaymiz
        fetchAppointments(for: Date())
    }
    
    private func setupSubscribers() {
        // Tanlangan kun o'zgarganda navbatlarni qayta tortish
        $selectedDate
            .removeDuplicates()
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] date in
                self?.fetchAppointments(for: date)
            }
            .store(in: &cancellables)

        // Navbatlar ro'yxati yangilanganda vaqt katakchalarini qayta generatsiya qilish
        $appointments
            .sink { [weak self] _ in
                self?.generateTimeSlots()
            }
            .store(in: &cancellables)
    }

    deinit {
        listenerRegistration?.remove()
    }
    
    // Pull-to-refresh uchun async funksiya
    @MainActor
    func handleRefresh() async {
        print("🔄 Handling refresh...")
        fetchAppointments(for: selectedDate)
    }

    // View ekrandan yo'qolganda (masalan, logout) chaqiriladi
    func clearData() {
        print("🗑️ Clearing data and listener.")
        self.appointments = []
        self.timeSlots = []
        listenerRegistration?.remove()
    }

    func fetchAppointments(for date: Date) {
        listenerRegistration?.remove()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        print("📡 Fetching appointments for \(date.formatted(date: .abbreviated, time: .omitted))...")
        
        listenerRegistration = db.collection("appointments")
            .whereField("appointmentTime", isGreaterThanOrEqualTo: startOfDay)
            .whereField("appointmentTime", isLessThan: endOfDay)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self, let documents = querySnapshot?.documents else {
                    self?.appointments = []
                    return
                }
                
                print("✅ Firestore listener updated with \(documents.count) documents.")
                self.appointments = documents.compactMap { try? $0.data(as: Appointment.self) }
            }
    }
    
    // Vaqt katakchalarini generatsiya qilish va band vaqtlarni belgilash
    private func generateTimeSlots() {
        var slots = [TimeSlot]()
        let calendar = Calendar.current
        
        // Sartarosh ish vaqti (masalan, 9:00 dan 19:00 gacha)
        guard let startTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: selectedDate),
              let endTime = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: selectedDate) else {
            self.timeSlots = []
            return
        }

        var currentTime = startTime
        while currentTime < endTime {
            var newSlot = TimeSlot(date: currentTime)
            
            // Shu vaqtda navbat bor yoki yo'qligini tekshirish
            let isBooked = appointments.contains { $0.appointmentTime == newSlot.date }
            
            // O'tib ketgan vaqtlarni ham band qilish
            if isBooked || (calendar.isDateInToday(selectedDate) && currentTime < Date()) {
                newSlot.isAvailable = false
            }
            
            slots.append(newSlot)
            
            // Keyingi vaqtga o'tish (30 daqiqa)
            currentTime = calendar.date(byAdding: .minute, value: 30, to: currentTime)!
        }
        
        self.timeSlots = slots
    }
    
    func addAppointment(for timeSlot: TimeSlot, name: String, phone: String, uid: String) {
        let newAppointment = Appointment(name: name, phone: phone, appointmentTime: timeSlot.date, status: .pending, userId: uid)
        
        do {
            _ = try db.collection("appointments").addDocument(from: newAppointment)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateAppointmentStatus(appointmentId: String, newStatus: AppointmentStatus) {
        db.collection("appointments").document(appointmentId).updateData(["status": newStatus.rawValue])
    }
} 