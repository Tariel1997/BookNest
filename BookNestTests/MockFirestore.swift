import Foundation
import FirebaseFirestore
@testable import BookNest

struct MockDocumentSnapshot {
    let data: [String: Any]
    
    func mockData() -> [String: Any] {
        return data
    }
}

struct MockQuerySnapshot {
    let documents: [MockDocumentSnapshot]
}

final class MockFirestoreCollection {
    var documents: [MockDocumentSnapshot] = []
    
    func getDocuments(completion: @escaping (MockQuerySnapshot?, Error?) -> Void) {
        let snapshot = MockQuerySnapshot(documents: documents)
        completion(snapshot, nil)
    }
}

final class MockFirestore {
    private var collections: [String: MockFirestoreCollection] = [:]
    
    func collection(_ name: String) -> MockFirestoreCollection {
        if collections[name] == nil {
            collections[name] = MockFirestoreCollection()
        }
        return collections[name]!
    }
}

final class HomePageViewModelForTest {
    private let mockDB: MockFirestore
    private(set) var books: [Book] = []
    var onBooksFetched: (() -> Void)?
    
    init(mockDB: MockFirestore) {
        self.mockDB = mockDB
    }
    
    func fetchBooks() {
        let mockCollection = mockDB.collection("books")
        mockCollection.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching books: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            self.books = documents.compactMap { doc in
                try? Firestore.Decoder().decode(Book.self, from: doc.mockData())
            }
            self.onBooksFetched?()
        }
    }
}

struct Book: Codable, Equatable {
    let title: String
    let author: String
}
