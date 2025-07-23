import Foundation
import FirebaseFirestore

enum AppointmentStatus: String, Codable, CaseIterable {
    case pending = "Kutilmoqda"
    case approved = "Tasdiqlandi"
    case rejected = "Rad etildi"
}

struct Appointment: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var phone: String
    var appointmentTime: Date
    var status: AppointmentStatus = .pending
    var userId: String // Qaysi foydalanuvchiga tegishli ekanligini bilish uchun
} 
