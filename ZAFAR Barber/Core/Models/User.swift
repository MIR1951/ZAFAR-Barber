import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String
    var phoneNumber: String
    var role: String = "user" // Default role
} 
