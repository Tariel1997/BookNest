import Foundation

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
        cartManager.addToCart(book: book) { result in
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
