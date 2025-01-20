import FirebaseFirestore
import FirebaseAuth

final class CartViewModel: ObservableObject {
    @Published var cartItems: [Book] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    private let db = Firestore.firestore()
    private let currentUserUID: String? = Auth.auth().currentUser?.uid
    private var listener: ListenerRegistration?
    
    func startListeningForCartItems() {
        guard let userId = currentUserUID else {
            self.errorMessage = "User not logged in."
            print("Error: User is not authenticated.")
            return
        }
        
        print("Starting to listen for cart items for userId: \(userId)")
        isLoading = true
        
        listener?.remove()
        
        listener = db.collection("Cart").document(userId).collection("Books")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to fetch cart items: \(error.localizedDescription)"
                    print("Firestore error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No books found in the cart."
                    print("No documents found in user's cart collection.")
                    self.cartItems = []
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
                    self.errorMessage = nil
                    print("Successfully fetched \(self.cartItems.count) items for userId: \(userId)")
                }
            }
    }
    
    func stopListeningForCartItems() {
        listener?.remove()
        listener = nil
        print("Stopped listening for cart items.")
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
                print("Successfully deleted book: \(book.title)")
            }
        }
    }
    
    deinit {
        stopListeningForCartItems()
    }
}
