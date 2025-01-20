import FirebaseFirestore
import FirebaseAuth

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let uid: String
    let email: String
    var name: String
    var surname: String
    var ImageUrl: String = ""
    var balance: Double
}
