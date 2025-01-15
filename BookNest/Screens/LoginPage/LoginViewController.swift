import UIKit
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private let viewModel = LogInViewModel()
    private var isLoggedIn = false
    
    private let bookNestLabel: UILabel = {
        let label = UILabel()
        label.text = "BookNest"
        label.font = UIFont(name: "Pacifico-Regular", size: 48)
        label.textColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        //label.textColor = .gray
        label.textColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your email address"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        //label.textColor = .gray
        label.textColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let newUserLabel: UILabel = {
        let label = UILabel()
        label.text = "New To BookNest?"
        label.font = UIFont.systemFont(ofSize: 12)
        //label.textColor = .gray
        label.textColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        button.setTitleColor(UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(navigateToSignup), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        
        let googleIcon = UIImage(named: "google_icon")
        let googleIconImageView = UIImageView(image: googleIcon)
        googleIconImageView.contentMode = .scaleAspectFit
        googleIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Continue With Google"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.black.withAlphaComponent(0.54)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [googleIconImageView, label])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            googleIconImageView.widthAnchor.constraint(equalToConstant: 23),
            googleIconImageView.heightAnchor.constraint(equalToConstant: 23)
        ])
        button.addTarget(self, action: #selector(continueWithGoogle), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(logIn), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPasswordField()
        
        if Auth.auth().currentUser != nil {
            isLoggedIn = true
            navigateToMainView()
        }
    }
    
    private func setupPasswordField() {
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        passwordTextField.rightView = eyeButton
        passwordTextField.rightViewMode = .always
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        
        view.addSubview(bookNestLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(newUserLabel)
        view.addSubview(signUpButton)
        view.addSubview(googleSignInButton)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            bookNestLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            bookNestLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            signUpButton.centerYAnchor.constraint(equalTo: newUserLabel.centerYAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            newUserLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            newUserLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            
            googleSignInButton.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -16),
            googleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            googleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func logIn() {
        viewModel.email = emailTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        viewModel.logIn()
        
        if viewModel.isLogedIn {
            navigateToMainView()
        } else {
            showAlert(message: viewModel.errorMessage ?? "An error occurred.")
        }
    }
    
    @objc private func continueWithGoogle() {
        viewModel.signInWithGmail(presentation: self) { error in
            if let error = error {
                print("Sign-In Failed: \(error.localizedDescription)")
            } else {
                self.viewModel.isLogedIn = true
                self.navigateToMainView()
            }
        }
    }
    
    @objc private func navigateToSignup() {
        let signupViewController = SignUpViewController()
        navigationController?.pushViewController(signupViewController, animated: true)
    }
    
    private func navigateToMainView() {
        let mainViewController = HomePageViewController()
        navigationController?.pushViewController(mainViewController, animated: true)
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        if let rightView = passwordTextField.rightView as? UIButton {
            rightView.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
