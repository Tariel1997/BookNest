import FirebaseFirestore
import FirebaseAuth

final class CartManager {
    private let db = Firestore.firestore()
    private let currentUserUID: String? = Auth.auth().currentUser?.uid
    
    func addToCart(book: Book, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = currentUserUID else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let cartRef = db.collection("Cart").document(uid).collection("Books").document(book.title)
        
        cartRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if document?.exists == true {
                completion(.failure(NSError(domain: "CartError", code: 409, userInfo: [NSLocalizedDescriptionKey: "This book is already in your cart."])))
            } else {
                let bookData: [String: Any] = [
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
                ]
                
                cartRef.setData(bookData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
