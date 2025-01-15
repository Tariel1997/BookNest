import UIKit

class MainPageViewController: UIViewController {
    private let viewModel = PostViewModel()
    
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
    
    private let authorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chapterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter", size: 15)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Leave a comment"
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindViewModel()
        
        viewModel.fetchPost(for: "george_rr_martin")
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(authorImageView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(chapterLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(commentTextField)
        
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
            
            authorImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            authorImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorImageView.widthAnchor.constraint(equalToConstant: 40),
            authorImageView.heightAnchor.constraint(equalToConstant: 40),
            
            authorLabel.centerYAnchor.constraint(equalTo: authorImageView.centerYAnchor, constant: -10),
            authorLabel.leadingAnchor.constraint(equalTo: authorImageView.trailingAnchor, constant: 8),
            
            dateLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: authorImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            chapterLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            chapterLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            chapterLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: chapterLabel.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            commentTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24),
            commentTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            commentTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            commentTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            commentTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onPostFetched = { [weak self] in
            guard let post = self?.viewModel.post else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            self?.authorLabel.text = post.authorName
            self?.dateLabel.text = dateFormatter.string(from: post.timestamp)
            self?.titleLabel.text = post.title
            self?.chapterLabel.text = "Chapter \(post.chapterNumber)"
            
            self?.updateContentLabelText(post.content)
            
            if let url = URL(string: post.authorImageURL) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            self?.authorImageView.image = UIImage(data: data)
                        }
                    }
                }
            }
        }
        
        viewModel.onError = { error in
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func updateContentLabelText(_ text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont(name: "Inter", size: 15) ?? UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.black
            ]
        )
        
        contentLabel.attributedText = attributedText
    }
}
