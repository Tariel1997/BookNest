import UIKit

final class BookDetailsViewController: UIViewController {
    
    private let viewModel: BookDetailsViewModel
    
    init(viewModel: BookDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
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
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AnekDevanagari", size: 16)
        label.textAlignment = .justified
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genresStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let authorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorRoleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Profile", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 12
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to cart", for: .normal)
        button.backgroundColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 230/255, alpha: 1)
        setupUI()
        configureData()
    }
    
    private func setupUI() {
        view.addSubview(bookImageView)
        view.addSubview(titleLabel)
        view.addSubview(authorLabel)
        view.addSubview(statsStackView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(genresStackView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(authorView)
        authorView.addSubview(authorImageView)
        authorView.addSubview(authorNameLabel)
        authorView.addSubview(authorRoleLabel)
        authorView.addSubview(viewProfileButton)
        view.addSubview(addToCartButton)
        
        NSLayoutConstraint.activate([
            bookImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30),
            bookImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookImageView.widthAnchor.constraint(equalToConstant: 160),
            bookImageView.heightAnchor.constraint(equalToConstant: 240),
            
            titleLabel.topAnchor.constraint(equalTo: bookImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statsStackView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addToCartButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            genresStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            genresStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            priceLabel.topAnchor.constraint(equalTo: genresStackView.bottomAnchor, constant: 16),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            authorView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 16),
            authorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            authorView.heightAnchor.constraint(equalToConstant: 70),
            authorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            authorImageView.leadingAnchor.constraint(equalTo: authorView.leadingAnchor, constant: 12),
            authorImageView.centerYAnchor.constraint(equalTo: authorView.centerYAnchor),
            authorImageView.widthAnchor.constraint(equalToConstant: 50),
            authorImageView.heightAnchor.constraint(equalToConstant: 50),
            
            authorRoleLabel.topAnchor.constraint(equalTo: authorImageView.topAnchor),
            authorRoleLabel.leadingAnchor.constraint(equalTo: authorImageView.trailingAnchor, constant: 12),
            
            authorNameLabel.topAnchor.constraint(equalTo: authorRoleLabel.bottomAnchor, constant: 4),
            authorNameLabel.leadingAnchor.constraint(equalTo: authorImageView.trailingAnchor, constant: 12),
            
            viewProfileButton.centerYAnchor.constraint(equalTo: authorView.centerYAnchor),
            viewProfileButton.trailingAnchor.constraint(equalTo: authorView.trailingAnchor, constant: -12),
            viewProfileButton.widthAnchor.constraint(equalToConstant: 100),
            viewProfileButton.heightAnchor.constraint(equalToConstant: 30),
            
            addToCartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addToCartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addToCartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addToCartButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        viewProfileButton.addTarget(self, action: #selector(viewProfileButtonTapped), for: .touchUpInside)
        addToCartButton.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
    }
    
    private func configureData() {
        titleLabel.text = viewModel.bookTitle
        authorLabel.text = viewModel.authorName
        priceLabel.text = viewModel.bookPrice
        descriptionLabel.text = viewModel.bookDescription
        
        if let url = URL(string: viewModel.bookImageURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.bookImageView.image = UIImage(data: data)
                    }
                }
            }
        }
        
        authorNameLabel.text = viewModel.authorName
        authorRoleLabel.text = "Author"
        
        if let authorImageUrl = viewModel.authorImageUrl, let url = URL(string: authorImageUrl) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.authorImageView.image = UIImage(data: data)
                    }
                }
            }
        }
        
        genresStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for genre in viewModel.bookGenres {
            let genreLabel = UILabel()
            genreLabel.text = genre
            genreLabel.font = UIFont.systemFont(ofSize: 14)
            genreLabel.textAlignment = .center
            genreLabel.textColor = .darkGray
            genreLabel.backgroundColor = UIColor(white: 0.9, alpha: 1)
            genreLabel.layer.cornerRadius = 12
            genreLabel.layer.masksToBounds = true
            genreLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let padding: CGFloat = 12
            genreLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
            genreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
            
            genreLabel.layoutMargins = UIEdgeInsets(top: 3, left: padding, bottom: 3, right: padding)
            
            genresStackView.addArrangedSubview(genreLabel)
        }
        
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let pagesLabel = createStatLabel(title: "Pages", value: viewModel.bookPages)
        let languageLabel = createStatLabel(title: "Language", value: viewModel.bookLanguage)
        let ratingLabel = createStatLabel(title: "Rating", value: viewModel.bookRating)
        
        statsStackView.addArrangedSubview(pagesLabel)
        statsStackView.addArrangedSubview(languageLabel)
        statsStackView.addArrangedSubview(ratingLabel)
    }
    
    private func createStatLabel(title: String, value: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.boldSystemFont(ofSize: 16)
        valueLabel.textColor = .black
        valueLabel.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    @objc private func viewProfileButtonTapped() {
        let authorProfileViewModel = AuthorProfileViewModel(authorID: viewModel.book.authorID)
        let authorProfileVC = AuthorProfileViewController(viewModel: authorProfileViewModel)
        authorProfileVC.modalPresentationStyle = .pageSheet
        
        if let sheet = authorProfileVC.sheetPresentationController {
            sheet.detents = [.large(), .medium()]
        }
        
        present(authorProfileVC, animated: true, completion: nil)
    }
    
    @objc private func addToCartButtonTapped() {
        viewModel.addToCart { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
