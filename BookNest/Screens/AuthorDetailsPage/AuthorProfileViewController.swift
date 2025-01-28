import UIKit
import SwiftUI

final class AuthorProfileViewController: UIViewController {
    
    private let viewModel: AuthorProfileViewModel
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    init(viewModel: AuthorProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateColors),
            name: .darkModeChanged,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Roboto-Medium", size: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AnekDevanagari", size: 16)
        label.textAlignment = .justified
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 230/255, alpha: 1)
        view.backgroundColor = isDarkMode ? .black : UIColor(red: 250/255, green: 245/255, blue: 230/255, alpha: 1)
        setupUI()
        fetchAuthorData()
        updateColors()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(bioLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            bioLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bioLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func fetchAuthorData() {
        viewModel.fetchAuthorDetails { [weak self] in
            self?.configureUI()
        }
    }
    
    private func configureUI() {
        nameLabel.text = viewModel.name
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        let attributedText = NSAttributedString(
            string: viewModel.bio,
            attributes: [
                .font: UIFont(name: "AnekDevanagari", size: 16) ?? UIFont.systemFont(ofSize: 16),
                .paragraphStyle: paragraphStyle
            ]
        )
        
        bioLabel.attributedText = attributedText
        
        if let authorImageUrl = viewModel.authorImageUrl, let url = URL(string: authorImageUrl) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    @objc private func updateColors() {
        let backgroundColor = isDarkMode ? UIColor.darkGray : UIColor(red: 250/255, green: 245/255, blue: 230/255, alpha: 1)
        let textColor = isDarkMode ? UIColor.white : UIColor.black
        //let secondaryTextColor = isDarkMode ? UIColor.lightGray : UIColor.darkGray
        
        view.backgroundColor = backgroundColor
        nameLabel.textColor = textColor
        bioLabel.textColor = textColor
        bioLabel.textAlignment = .justified
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeChanged, object: nil)
    }
}
