import SwiftUI
import FirebaseAuth

final class ProfileViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var errorMessage: String?
    @Published var showAlert: Bool = false
    
    func fetchUserData() {
        if let currentUser = Auth.auth().currentUser {
            userEmail = currentUser.email ?? "Unknown"
        } else {
            userEmail = "Guest"
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            navigateToLogin()
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showAlert = true
    }
    
    private func navigateToLogin() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        
        let loginViewController = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
