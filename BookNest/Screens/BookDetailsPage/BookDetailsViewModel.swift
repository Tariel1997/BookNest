import Foundation
import FirebaseAuth
import FirebaseFirestore

final class BookDetailsViewModel {
    
    public let book: Book
    private let cartManager = CartManager()
    
    init(book: Book) {
        self.book = book
    }
    
    var bookTitle: String {
        book.title
    }
    
    var authorName: String {
        book.authorName
    }
    
    var authorImageUrl: String? {
        book.authorImageUrl
    }
    
    var bookImageURL: String {
        book.imageUrl
    }
    
    var bookPrice: String {
        "$\(book.price)"
    }
    
    var bookDescription: String {
        book.description
    }
    
    var bookGenres: [String] {
        book.genres
    }
    
    var bookPages: String {
        "\(book.pages)"
    }
    
    var bookLanguage: String {
        book.language
    }
    
    var bookRating: String {
        String(format: "%.1f", book.rating)
    }
    
    func addToCart(completion: @escaping (String) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion("User not logged in.")
            return
        }
        
        let userBooksRef = Firestore.firestore().collection("Users").document(userId).collection("Books").document(book.title)
        
        userBooksRef.getDocument { document, error in
            if let error = error {
                completion("Failed to check purchased books: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                completion("You already own this book.")
            } else {
                self.cartManager.addToCart(book: self.book) { result in
                    switch result {
                    case .success:
                        completion("Book successfully added to cart.")
                    case .failure(let error):
                        if (error as NSError).code == 409 {
                            completion("This book is already in your cart.")
                        } else {
                            completion("Failed to add book to cart: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
