import Foundation
import FirebaseFirestore

final class AuthorProfileViewModel {
    private let authorID: String
    private let db = Firestore.firestore()
    
    private(set) var name: String = ""
    private(set) var bio: String = ""
    private(set) var authorImageUrl: String?
    
    init(authorID: String) {
        self.authorID = authorID
    }
    
    func fetchAuthorDetails(completion: @escaping () -> Void) {
        db.collection("authors").document(authorID).getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error fetching author data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self?.name = data["name"] as? String ?? "Unknown"
            self?.bio = data["bio"] as? String ?? "No bio available"
            self?.authorImageUrl = data["authorImageUrl"] as? String
            completion()
        }
    }
}
