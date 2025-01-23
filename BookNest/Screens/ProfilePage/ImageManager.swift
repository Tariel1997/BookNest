import FirebaseStorage
import FirebaseFirestore
import UIKit

class ImageManager {
    static let shared = ImageManager()
    private let cacheStorage = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    private let firestore = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    func cacheImage(image: UIImage, fileName: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let fileURL = cacheStorage.appendingPathComponent(fileName)
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Error caching image: \(error.localizedDescription)")
        }
    }
    
    func getCachedImage(fileName: String) -> UIImage? {
        let fileURL = cacheStorage.appendingPathComponent(fileName)
        guard let imageData = try? Data(contentsOf: fileURL), let image = UIImage(data: imageData) else {
            return nil
        }
        return image
    }
    
    func clearCache(for fileName: String) {
        let fileURL = cacheStorage.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Cache cleared for image: \(fileName)")
        } catch {
            print("Error clearing cache: \(error.localizedDescription)")
        }
    }
    
    func fetchImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        let fileName = self.fileName(from: url)
        
        if let cachedImage = getCachedImage(fileName: fileName) {
            completion(cachedImage)
            return
        }
        
        let storageRef = storage.reference(forURL: url)
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error fetching image from Firebase Storage: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                self.cacheImage(image: image, fileName: fileName)
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    func uploadImage(_ image: UIImage, for userID: String, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error compressing image")
            completion(nil)
            return
        }
        
        let fileName = "\(userID).jpg"
        let storageRef = storage.reference().child("profile_images/\(fileName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    completion(nil)
                } else if let url = url {
                    let downloadURL = url.absoluteString
                    self.updateImageURL(downloadURL, for: userID)
                    self.cacheImage(image: image, fileName: fileName)
                    completion(downloadURL)
                }
            }
        }
    }
    
    func updateImageURL(_ url: String, for userID: String) {
        let userRef = firestore.collection("Users").document(userID)
        userRef.updateData(["ImageUrl": url]) { error in
            if let error = error {
                print("Error updating Firestore ImageUrl: \(error.localizedDescription)")
            } else {
                print("Firestore ImageUrl updated successfully.")
            }
        }
    }
    
    private func fileName(from url: String) -> String {
        return url.components(separatedBy: "/").last ?? "defaultImage.jpg"
    }
}
