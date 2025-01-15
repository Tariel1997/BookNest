import UIKit

final class HomePageCell: UICollectionViewCell {
    
    static let identifier = "BookCell"
    
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AnekDevanagari-Bold", size: 18)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Roboto-Medium", size: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter", size: 14)
        label.textColor = .orange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var genresStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var infoStackView: UIStackView = {
        let spacer1 = UIView()
        let spacer2 = UIView()
        let spacer3 = UIView()
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, spacer1, authorLabel, spacer2, ratingLabel, spacer3, genresStackView])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(bookImageView)
        contentView.addSubview(infoStackView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bookImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bookImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            bookImageView.widthAnchor.constraint(equalToConstant: 80),
            bookImageView.heightAnchor.constraint(equalToConstant: 120),
            
            infoStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            infoStackView.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 8),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            infoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.authorName
        ratingLabel.text = "Rating: \(book.rating)"
        genresStackView.arrangedSubviews.forEach { $0.removeFromSuperview()}
        
        for genre in book.genres {
            let genreLabel = UILabel()
            genreLabel.text = genre
            genreLabel.font = UIFont(name: "Roboto", size: 14)
            genreLabel.textColor = .darkGray
            genreLabel.textAlignment = .center
            genreLabel.backgroundColor = UIColor(white: 0.9, alpha: 1)
            genreLabel.layer.cornerRadius = 12
            genreLabel.layer.masksToBounds = true
            genreLabel.translatesAutoresizingMaskIntoConstraints = false
            genreLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
            genreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 65).isActive = true
            genresStackView.addArrangedSubview(genreLabel)
        }
        
        if let url = URL(string: book.imageUrl) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.bookImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}
