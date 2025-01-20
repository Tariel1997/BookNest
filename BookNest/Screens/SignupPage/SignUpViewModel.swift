import Foundation
import FirebaseAuth
import Firebase

final class SignUpViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var statusMessage: String? = nil
    @Published var isSuccess: Bool = false
    @Published var shouldNavigateToLogin: Bool = false
    
    func validateForm() -> (isValid: Bool, message: String?) {
        guard !fullName.isEmpty, !userName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            return (false, "All fields are required.")
        }
        guard isValidEmail(email) else {
            return (false, "Please enter a valid email address.")
        }
        guard password.count >= 6 else {
            return (false, "Password must be at least 6 characters long.")
        }
        guard password == confirmPassword else {
            return (false, "Passwords do not match.")
        }
        return (true, nil)
    }
    
    func SignUp() async {
        let validationResult = validateForm()
        
        DispatchQueue.main.async { [weak self] in
            self?.statusMessage = validationResult.message
        }
        if !validationResult.isValid {
            return
        }
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            saveUserInfo()
            
            DispatchQueue.main.async { [weak self] in
                self?.statusMessage = "Sign-up successful!"
                self?.isSuccess = true
                self?.shouldNavigateToLogin = true
            }
        }
        catch {
            DispatchQueue.main.async { [weak self] in
                self?.statusMessage = "Error during sign-up: \(error.localizedDescription)"
            }
        }
    }
    
    //    func saveUserInfo() {
    //        let firestore = Firestore.firestore()
    //        guard let id = Auth.auth().currentUser?.uid else { return }
    //        guard let mail = Auth.auth().currentUser?.email else { return }
    //        let user = User(uid: id, email: mail, name: userName, surname: fullName)
    //        do {
    //            try firestore.collection("Users")
    //                .document(id)
    //                .setData(from: user) { error in
    //                    if let error = error {
    //                        print("failed to save user data \(user)")
    //                    }
    //                }
    //        } catch {
    //            print("failed saving user data")
    //        }
    //    }
    
    func saveUserInfo() {
        let firestore = Firestore.firestore()
        guard let id = Auth.auth().currentUser?.uid else { return }
        guard let mail = Auth.auth().currentUser?.email else { return }
        
        let user = User(uid: id, email: mail, name: userName, surname: fullName, balance: 1000.0)
        
        do {
            try firestore.collection("Users")
                .document(id)
                .setData(from: user) { error in
                    if let error = error {
                        print("Failed to save user data: \(error.localizedDescription)")
                    } else {
                        print("User successfully saved!")
                        self.createEmptyBooksCollection(for: id)
                    }
                }
        } catch {
            print("Failed to save user data: \(error.localizedDescription)")
        }
    }
    
    // Create an empty "Books" subcollection
    private func createEmptyBooksCollection(for userId: String) {
        let firestore = Firestore.firestore()
        firestore.collection("Users").document(userId).collection("Books").document("placeholder").setData(["empty": true]) { error in
            if let error = error {
                print("Failed to create empty books collection: \(error.localizedDescription)")
            } else {
                print("Empty books collection created successfully!")
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
}
