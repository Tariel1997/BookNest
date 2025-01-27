import FirebaseFirestore
import FirebaseAuth

final class BookDetailViewModel: ObservableObject {
    @Published var book: Book? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    private let userId = Auth.auth().currentUser?.uid
    
    func fetchBook(bookId: String) {
        guard let userId = userId else {
            self.errorMessage = "User not logged in."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        db.collection("Users")
            .document(userId)
            .collection("Books")
            .document(bookId)
            .getDocument { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to fetch book: \(error.localizedDescription)"
                    }
                    return
                }
                
                if let _ /*data*/ = snapshot?.data(), let book = try? snapshot?.data(as: Book.self) {
                    DispatchQueue.main.async {
                        self?.book = book
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Book not found."
                    }
                }
            }
    }
}
