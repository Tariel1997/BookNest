import FirebaseFirestore
import FirebaseAuth

final class CartViewModel: ObservableObject {
    @Published var cartItems: [Book] = []
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    private let currentUserUID: String? = Auth.auth().currentUser?.uid
    
    func fetchCartItems() {
        guard let userId = currentUserUID else {
            self.errorMessage = "User not logged in."
            print("Error: User is not authenticated.")
            return
        }
        
        print("Fetching cart items for userId: \(userId)")
        
        db.collection("Cart").document(userId).collection("Books").getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch cart items: \(error.localizedDescription)"
                print("Firestore error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.errorMessage = "No books found in the cart."
                print("No documents found in user's cart collection.")
                return
            }
            
            self.cartItems = documents.compactMap { doc -> Book? in
                do {
                    print("Document data: \(doc.data())")
                    return try doc.data(as: Book.self)
                } catch {
                    print("Error decoding book document: \(error.localizedDescription)")
                    return nil
                }
            }
            
            if self.cartItems.isEmpty {
                self.errorMessage = "Your cart is empty."
                print("Cart is empty for userId: \(userId)")
            } else {
                print("Successfully fetched \(self.cartItems.count) items for userId: \(userId)")
            }
        }
    }
    
    func deleteBookFromCart(book: Book) {
        guard let userId = currentUserUID else {
            print("Error: User is not authenticated.")
            return
        }
        
        print("Deleting book: \(book.title) for userId: \(userId)")
        
        db.collection("Cart").document(userId).collection("Books").document(book.title).delete { error in
            if let error = error {
                print("Failed to delete book: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.cartItems.removeAll { $0.title == book.title }
                    print("Successfully deleted book: \(book.title)")
                }
            }
        }
    }
}
