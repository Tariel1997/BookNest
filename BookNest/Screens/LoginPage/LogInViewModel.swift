import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import Firebase

class LogInViewModel: ObservableObject {
    @Published var email: String
    @Published var password: String
    @Published var errorMessage: String?
    @Published var showAlert: Bool = false
    @Published var isLogedIn: Bool = false
    
    init(email: String = "", password: String = "") {
        self.email = email
        self.password = password
        self.isLogedIn = Auth.auth().currentUser != nil
    }
    
    //    func logIn() {
    //        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
    //            if let error = error {
    //                self?.handleError(error)
    //                return
    //            }
    //            self?.isLogedIn = true
    //            self?.password = ""
    //            self?.email = ""
    //        }
    //    }
    
    func logIn(completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.handleError(error)
                completion(.failure(error))
                return
            }
            self?.isLogedIn = true
            self?.password = ""
            self?.email = ""
            completion(.success(()))
        }
    }
    
    private func handleError(_ error: Error) {
        if let authError = error as NSError? {
            switch AuthErrorCode(rawValue: authError.code) {
            case .networkError:
                errorMessage = "Network error. Please check your internet connection."
            case .userNotFound:
                errorMessage = "No user found with this email address."
            case .wrongPassword:
                errorMessage = "Incorrect password. Please try again."
            case .invalidEmail:
                errorMessage = "The email address is not valid."
            case .tooManyRequests:
                errorMessage = "Too many login attempts. Please try again later."
            default:
                errorMessage = "An unknown error occurred. Please try again."
            }
        } else {
            errorMessage = error.localizedDescription
        }
        
        showAlert = true
        print("Login Error: \(errorMessage ?? error.localizedDescription)")
    }
    
    func signInWithGmail(presentation: UIViewController, completion: @escaping (Error?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(NSError(domain: "SignInError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase clientID not found."]))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentation) { result, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(NSError(domain: "SignInError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user or ID token."]))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [weak self]  authResult, error in
                if let error = error {
                    completion(error)
                    return
                }
                completion(nil)
                self?.isLogedIn = true
                self?.password = ""
                self?.email = ""
            }
        }
    }
}
