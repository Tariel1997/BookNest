import FirebaseFirestore

struct Book: Codable {
    let authorID: String
    let authorImageUrl: String
    let authorName: String
    let description: String
    let imageUrl: String
    let language: String
    let pages: Int
    let pdfUrl: String
    let price: Double
    let rating: Double
    let title: String
    let genres: [String]
}
