import FirebaseFirestore
import FirebaseAuth

final class CartViewModel: ObservableObject {
    @Published var cartItems: [Book] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var userBalance: Double = 0.0
    
    var totalAmount: Double {
        cartItems.reduce(0) { $0 + $1.price }
    }
    
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
        fetchUserBalance(for: userId)
    }
    
    private func fetchUserBalance(for userId: String) {
        db.collection("Users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user balance: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data(), let balance = data["balance"] as? Double {
                DispatchQueue.main.async {
                    self?.userBalance = balance
                }
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
    
    func checkOut(completion: @escaping (String) -> Void) {
        if userBalance < totalAmount {
            completion("Insufficient balance to complete the purchase.")
            return
        }
        
        guard let userId = currentUserUID else {
            completion("User not logged in.")
            return
        }
        
        let userRef = db.collection("Users").document(userId)
        let userBooksRef = userRef.collection("Books")
        
        let newBalance = userBalance - totalAmount
        userRef.updateData(["balance": newBalance]) { [weak self] error in
            if let error = error {
                completion("Error updating balance: \(error.localizedDescription)")
                return
            }
            
            let batch = self?.db.batch()
            self?.cartItems.forEach { book in
                let bookRef = userBooksRef.document(book.title)
                batch?.setData([
                    "authorID": book.authorID,
                    "authorImageUrl": book.authorImageUrl,
                    "authorName": book.authorName,
                    "description": book.description,
                    "imageUrl": book.imageUrl,
                    "language": book.language,
                    "pages": book.pages,
                    "pdfUrl": book.pdfUrl,
                    "price": book.price,
                    "rating": book.rating,
                    "title": book.title,
                    "genres": book.genres
                ], forDocument: bookRef)
            }
            
            let cartRef = self?.db.collection("Cart").document(userId).collection("Books")
            self?.cartItems.forEach { book in
                cartRef?.document(book.title).delete()
            }
            
            batch?.commit { error in
                if let error = error {
                    completion("Error completing checkout: \(error.localizedDescription)")
                } else {
                    self?.cartItems.removeAll()
                    self?.userBalance = newBalance
                    completion("Checkout successful! Your books have been purchased.")
                }
            }
        }
    }
    
    deinit {
        stopListeningForCartItems()
    }
}
