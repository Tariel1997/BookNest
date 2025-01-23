import SwiftUI
import FirebaseAuth
import FirebaseFirestore

final class ProfileViewModel: ObservableObject {
    @Published var profile = User(uid: "", email: "", name: "", surname: "", ImageUrl: "", balance: 0.0)
    @Published var profileImage: UIImage? = nil
    @Published var isLoading: Bool = false
    
    init() {
        fetchUser()
    }
    
    private func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }
        
        let firestore = Firestore.firestore()
        isLoading = true
        
        firestore.collection("Users")
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    return
                }
                
                if let user = try? snapshot?.data(as: User.self) {
                    DispatchQueue.main.async {
                        self.profile = user
                        if !user.ImageUrl.isEmpty {
                            self.loadProfileImage(from: user.ImageUrl)
                        }
                    }
                }
            }
    }
    
    private func loadProfileImage(from urlString: String) {
        ImageManager.shared.fetchImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                self?.profileImage = image
            }
        }
    }
    
    func uploadProfileImage() {
        guard let profileImage = profileImage else {
            print("No profile image selected")
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        ImageManager.shared.uploadImage(profileImage, for: userId) { [weak self] url in
            if let url = url {
                DispatchQueue.main.async {
                    self?.profile.ImageUrl = url
                }
            } else {
                print("Failed to upload profile image.")
            }
        }
    }
    
    func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let updatedUser = User(
            uid: userId,
            email: profile.email,
            name: profile.name,
            surname: profile.surname,
            ImageUrl: profile.ImageUrl,
            balance: profile.balance
        )
        
        do {
            try db.collection("Users").document(userId).setData(from: updatedUser) { error in
                if let error = error {
                    print("Failed to save profile: \(error.localizedDescription)")
                } else {
                    print("Profile successfully saved.")
                }
            }
        } catch {
            print("Error saving user data: \(error.localizedDescription)")
        }
    }
}
