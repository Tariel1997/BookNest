import Foundation
import FirebaseFirestore

class PostViewModel {
    
    private let db = Firestore.firestore()
    var post: Post?
    var onPostFetched: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    func fetchPost(for authorID: String) {
        db.collection("posts")
            .whereField("authorID", isEqualTo: authorID)
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.onError?(error)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    self?.onError?(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No post found"]))
                    return
                }
                
                var postData = document.data()
                postData["id"] = document.documentID
                
                self?.fetchAuthorDetails(authorID: authorID) { authorName, authorImageURL in
                    postData["authorName"] = authorName
                    postData["authorImageURL"] = authorImageURL
                    if let post = Post(document: postData) {
                        self?.post = post
                        self?.onPostFetched?()
                    } else {
                        self?.onError?(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse post"]))
                    }
                }
            }
    }
    
    private func fetchAuthorDetails(authorID: String, completion: @escaping (String, String) -> Void) {
        db.collection("authors").document(authorID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching author details: \(error.localizedDescription)")
                completion("Unknown Author", "")
            } else if let data = snapshot?.data(),
                      let name = data["name"] as? String,
                      let profileImageURL = data["profileImageURL"] as? String {
                completion(name, profileImageURL)
            } else {
                completion("Unknown Author", "")
            }
        }
    }
    
    private func fetchAuthorName(authorID: String, completion: @escaping (String) -> Void) {
        db.collection("users").document(authorID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching author name: \(error.localizedDescription)")
                completion("Unknown Author")
            } else if let name = snapshot?.data()?["name"] as? String {
                completion(name)
            } else {
                completion("Unknown Author")
            }
        }
    }
}
