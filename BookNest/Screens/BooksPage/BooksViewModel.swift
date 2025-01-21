import Foundation
import FirebaseFirestore
import FirebaseAuth

final class BooksViewModel: ObservableObject {
    @Published var userBooks: [Book] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    private let currentUserUID: String? = Auth.auth().currentUser?.uid
    
    func fetchUserBooks() {
        guard let userId = currentUserUID else {
            self.errorMessage = "User not logged in."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        db.collection("Users").document(userId).collection("Books")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch books: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No books found."
                    }
                    return
                }
                
                let books = documents.compactMap { doc -> Book? in
                    do {
                        return try doc.data(as: Book.self)
                    } catch {
                        print("Error decoding book document: \(error)")
                        return nil
                    }
                }
                
                DispatchQueue.main.async {
                    self.userBooks = books
                }
            }
    }
}
