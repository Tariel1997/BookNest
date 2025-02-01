import Combine
import FirebaseFirestore
import FirebaseAuth

final class BookDetailViewModel: ObservableObject {
    @Published var book: Book? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isDownloading: Bool = false
    @Published var isDownloadingForReading: Bool = false
    @Published var downloadProgress: Float = 0.0
    @Published var isDownloaded: Bool = false
    @Published var fileToPreview: URL? = nil
    @Published var showPDFPreview: Bool = false
    
    private let db = Firestore.firestore()
    private let userId = Auth.auth().currentUser?.uid
    
    func fetchBook(bookId: String) {
        guard let userId = userId else {
            self.errorMessage = "User not logged in."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        db.collection("Users")
            .document(userId)
            .collection("Books")
            .document(bookId)
            .getDocument { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to fetch book: \(error.localizedDescription)"
                    }
                    return
                }
                
                if let _ = snapshot?.data(), let book = try? snapshot?.data(as: Book.self) {
                    DispatchQueue.main.async {
                        self?.book = book
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Book not found."
                    }
                }
            }
    }
    
    func downloadPDF(from urlString: String, bookTitle: String, saveToFiles: Bool) {
        guard !isDownloading else { return }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        let sanitizedTitle = bookTitle
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
        
        let session = URLSession(configuration: .default, delegate: DownloadDelegate(progressHandler: { [weak self] progress in
            DispatchQueue.main.async {
                if !(self?.isDownloadingForReading ?? false) {
                    self?.downloadProgress = progress
                }
            }
        }, completionHandler: { [weak self] fileURL in
            DispatchQueue.main.async {
                self?.isDownloading = false
                self?.isDownloaded = true
                
                if let fileURL = fileURL {
                    if saveToFiles {
                        self?.savePDFToFiles(fileURL: fileURL, bookTitle: sanitizedTitle)
                    } else {
                        self?.fileToPreview = fileURL
                        self?.showPDFPreview = true
                        print("PDF ready for reading: \(fileURL.path)")
                    }
                } else {
                    print("Error: fileURL is nil")
                }
            }
        }, errorHandler: { [weak self] error in
            DispatchQueue.main.async {
                self?.isDownloading = false
                self?.errorMessage = "Failed to download PDF: \(error.localizedDescription)"
                print("Error downloading PDF: \(error.localizedDescription)")
            }
        }), delegateQueue: .main)
        
        isDownloading = true
        isDownloadingForReading = !saveToFiles
        downloadProgress = 0.0
        
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    private func savePDFToFiles(fileURL: URL, bookTitle: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsPath.appendingPathComponent("\(bookTitle).pdf")
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.moveItem(at: fileURL, to: destinationURL)
            print("PDF saved at \(destinationURL.path)")
            
            let fileExists = FileManager.default.fileExists(atPath: destinationURL.path)
            print("File exists after saving: \(fileExists)")
            
            DispatchQueue.main.async {
                let documentPicker = UIDocumentPickerViewController(forExporting: [destinationURL])
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(documentPicker, animated: true, completion: nil)
                }
            }
        } catch {
            print("Error saving PDF to files: \(error.localizedDescription)")
        }
    }
    
    deinit {
        print("BookDetailViewModel deinitialized")
    }
}


extension BookDetailViewModel {
    func downloadAndReadPDF(from urlString: String) {
        guard !isDownloading else { return }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        let session = URLSession(configuration: .default, delegate: DownloadDelegate(progressHandler: { [weak self] progress in
            DispatchQueue.main.async {
                self?.downloadProgress = progress
            }
        }, completionHandler: { [weak self] fileURL in
            DispatchQueue.main.async {
                self?.isDownloading = false
                self?.isDownloaded = true
                
                if let fileURL = fileURL {
                    self?.fileToPreview = fileURL
                    self?.showPDFPreview = true
                    print("File ready for reading: \(fileURL.path)")
                } else {
                    print("Error: fileURL is nil")
                }
            }
        }, errorHandler: { [weak self] error in
            DispatchQueue.main.async {
                self?.isDownloading = false
                self?.errorMessage = "Failed to download and read PDF: \(error.localizedDescription)"
                print("Error downloading PDF: \(error.localizedDescription)")
            }
        }), delegateQueue: .main)
        
        isDownloading = true
        downloadProgress = 0.0
        
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    
    func downloadAndSavePDFToFiles(from urlString: String, bookTitle: String) {
        guard !isDownloading else { return }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        let sanitizedTitle = bookTitle
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
        
        let session = URLSession(configuration: .default, delegate: DownloadDelegate(progressHandler: { [weak self] progress in
            DispatchQueue.main.async {
                self?.downloadProgress = progress
            }
        }, completionHandler: { [weak self] fileURL in
            DispatchQueue.main.async {
                self?.isDownloading = false
                self?.isDownloaded = true
                
                if let fileURL = fileURL {
                    self?.savePDFToFiles(fileURL: fileURL, bookTitle: sanitizedTitle)
                } else {
                    print("Error: fileURL is nil")
                }
            }
        }, errorHandler: { [weak self] error in
            DispatchQueue.main.async {
                self?.isDownloading = false
                self?.errorMessage = "Failed to download and save PDF: \(error.localizedDescription)"
                print("Error downloading PDF: \(error.localizedDescription)")
            }
        }), delegateQueue: .main)
        
        isDownloading = true
        downloadProgress = 0.0
        
        let task = session.downloadTask(with: url)
        task.resume()
    }
}
