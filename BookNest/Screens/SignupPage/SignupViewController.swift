import UIKit
import Combine
import FirebaseAuth
import Firebase

final class SignUpViewController: UIViewController {
    
    private let viewModel = SignUpViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign up"
        label.textColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        label.font = UIFont(name: "ABeeZee", size: 24)
        //label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Name"
        label.font = UIFont.systemFont(ofSize: 14)
        //label.textColor = .gray
        label.textColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let fullNameField = UITextField()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.systemFont(ofSize: 14)
        //label.textColor = .gray
        label.textColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let userNameField = UITextField()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.systemFont(ofSize: 14)
        //label.textColor = .gray
        label.textColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let emailField = UITextField()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = UIFont.systemFont(ofSize: 14)
        //label.textColor = .gray
        label.textColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //private let passwordField = UITextField()
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.rightViewMode = .always
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        textField.rightView = eyeButton
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm Password"
        label.font = UIFont.systemFont(ofSize: 14)
        //label.textColor = .gray
        label.textColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //private let confirmPasswordField = UITextField()
    
    
    private let confirmPasswordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.rightViewMode = .always
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)
        textField.rightView = eyeButton
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let statusMessageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        [titleLabel,
         fullNameLabel, fullNameField,
         userNameLabel, userNameField,
         emailLabel, emailField,
         passwordLabel, passwordField,
         confirmPasswordLabel, confirmPasswordField,
         signUpButton, statusMessageLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        configureTextField(fullNameField, placeholder: "Full Name")
        configureTextField(userNameField, placeholder: "Username")
        configureTextField(emailField, placeholder: "Email", isSecure: false)
        configureTextField(passwordField, placeholder: "Password", isSecure: true)
        configureTextField(confirmPasswordField, placeholder: "Confirm Password", isSecure: true)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            fullNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            fullNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fullNameField.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8),
            fullNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fullNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            fullNameField.heightAnchor.constraint(equalToConstant: 44),
            
            userNameLabel.topAnchor.constraint(equalTo: fullNameField.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userNameField.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            userNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            userNameField.heightAnchor.constraint(equalToConstant: 44),
            
            emailLabel.topAnchor.constraint(equalTo: userNameField.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emailField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 8),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            passwordField.heightAnchor.constraint(equalToConstant: 44),
            
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 8),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmPasswordField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 8),
            confirmPasswordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmPasswordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 44),
            
            signUpButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 16),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            signUpButton.heightAnchor.constraint(equalToConstant: 48),
            
            statusMessageLabel.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 16),
            statusMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
    }
    
    @objc private func togglePasswordVisibility(sender: UIButton) {
        passwordField.isSecureTextEntry.toggle()
        let imageName = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func toggleConfirmPasswordVisibility(sender: UIButton) {
        confirmPasswordField.isSecureTextEntry.toggle()
        let imageName = confirmPasswordField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String, isSecure: Bool = false) {
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
    }
    
    private func bindViewModel() {
        viewModel.$statusMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.statusMessageLabel.text = message
                self?.statusMessageLabel.textColor = self?.viewModel.isSuccess == true ? .green : .red
            }
            .store(in: &cancellables)
        
        viewModel.$isSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccess in
                if isSuccess {
                    print("Sign-up successful!")
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func textFieldChanged(_ sender: UITextField) {
        switch sender {
        case fullNameField:
            viewModel.fullName = sender.text ?? ""
        case userNameField:
            viewModel.userName = sender.text ?? ""
        case emailField:
            viewModel.email = sender.text ?? ""
        case passwordField:
            viewModel.password = sender.text ?? ""
        case confirmPasswordField:
            viewModel.confirmPassword = sender.text ?? ""
        default:
            break
        }
    }
    
    @objc private func signUpTapped() {
        Task {
            await viewModel.SignUp()
        }
    }
}
