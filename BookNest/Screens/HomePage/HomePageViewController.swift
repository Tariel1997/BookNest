import UIKit

final class HomePageViewController: UIViewController {
    
    private let viewModel = HomePageViewModel()
    private var filteredBooks: [Book] = []
    private var isSearching = false
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular Books"
        label.font = UIFont(name: "Pacifico-Regular", size: 24)
        label.textColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search books, authors, genres"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.cornerRadius = 12
        searchBar.layer.masksToBounds = true
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = UIColor(white: 0.9, alpha: 1)
        searchBar.searchTextField.layer.cornerRadius = 12
        searchBar.searchTextField.clipsToBounds = true
        return searchBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 16, height: 135)
        layout.minimumLineSpacing = 4
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 230/255, alpha: 1)
        collectionView.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 230/255, alpha: 1)
        
        searchBar.delegate = self
        collectionView.register(HomePageCell.self, forCellWithReuseIdentifier: HomePageCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        setupConstraints()
        bindViewModel()
        viewModel.fetchBooks()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onBooksFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.filteredBooks = self?.viewModel.books ?? []
                self?.collectionView.reloadData()
            }
        }
    }
}

extension HomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredBooks.count : viewModel.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePageCell.identifier, for: indexPath) as? HomePageCell else {
            return UICollectionViewCell()
        }
        let book = isSearching ? filteredBooks[indexPath.item] : viewModel.books[indexPath.item]
        cell.configure(with: book)
        return cell
    }
}

extension HomePageViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            isSearching = false
            filteredBooks.removeAll()
            collectionView.reloadData()
            return
        }
        
        isSearching = true
        filteredBooks = viewModel.books.filter { book in
            book.title.lowercased().contains(searchText.lowercased()) ||
            book.authorName.lowercased().contains(searchText.lowercased()) ||
            book.genres.contains { $0.lowercased().contains(searchText.lowercased()) }
        }
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        filteredBooks.removeAll()
        collectionView.reloadData()
        searchBar.resignFirstResponder()
    }
}
