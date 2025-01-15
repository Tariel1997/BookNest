import UIKit
import FirebaseFirestore

final class HomePageViewModel {
    private let db = Firestore.firestore()
    private(set) var books: [Book] = []
    var onBooksFetched: (() -> Void)?
    
    func fetchBooks() {
        db.collection("books").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching books: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            self.books = documents.compactMap { doc in
                try? doc.data(as: Book.self)
            }
            self.onBooksFetched?()
        }
    }
}
