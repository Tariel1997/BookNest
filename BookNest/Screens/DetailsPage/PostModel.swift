import FirebaseFirestore
import Foundation

struct Post {
    let id: String
    let authorName: String
    let authorImageURL: String
    let title: String
    let chapterNumber: Int
    let content: String
    let timestamp: Date
    
    init?(document: [String: Any]) {
        guard let id = document["id"] as? String,
              let authorName = document["authorName"] as? String,
              let authorImageURL = document["authorImageURL"] as? String,
              let title = document["title"] as? String,
              let chapterNumber = document["chapterNumber"] as? Int,
              let content = document["content"] as? String,
              let timestamp = document["timestamp"] as? Timestamp else {
            return nil
        }
        
        self.id = id
        self.authorName = authorName
        self.authorImageURL = authorImageURL
        self.title = title
        self.chapterNumber = chapterNumber
        self.content = content
        self.timestamp = timestamp.dateValue()
    }
}
