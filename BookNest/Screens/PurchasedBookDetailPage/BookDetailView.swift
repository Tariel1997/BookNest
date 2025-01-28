import SwiftUI
import PDFKit

struct BookDetailView: View {
    @StateObject private var viewModel = BookDetailViewModel()
    let bookId: String
    
    @State private var fileToPreview: URL? = nil
    @State private var showPDFPreview = false
    @State private var downloadProgress: Float = 0.0
    @State private var isDownloading: Bool = false
    @State private var isDownloaded: Bool = false
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading book details...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if let book = viewModel.book {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        Text(book.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.vertical)
                        Spacer()
                    }
                    
                    HStack(alignment: .top, spacing: 16) {
                        AsyncImage(url: URL(string: book.imageUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 200)
                                    .cornerRadius(12)
                            } else if phase.error != nil {
                                Color.red
                                    .frame(width: 140, height: 200)
                                    .cornerRadius(12)
                            } else {
                                Color.gray.opacity(0.3)
                                    .frame(width: 140, height: 200)
                                    .cornerRadius(12)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Author: \(book.authorName)")
                                //.font(.subheadline)
                                .font(.inter(size: 16))
                                .foregroundColor(.gray)
                            
                            Text("Category: \(book.genres.joined(separator: ", "))")
                                //.font(.subheadline)
                                .font(.roboto(size: 16))
                                .foregroundColor(.gray)
                            
                            Text("Rating: \(String(format: "%.2f", book.rating)) / 5")
                                //.font(.subheadline)
                                .font(.robotoMedium(size: 16))
                                .foregroundColor(.orange)
                            
                            Text("Pricing: \(String(format: "$%.2f", book.price))")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            if isDownloading {
                                VStack {
                                    Text("Downloading...")
                                    ProgressView(value: downloadProgress)
                                        .progressViewStyle(LinearProgressViewStyle())
                                        .padding(.top, 8)
                                }
                            } else if isDownloaded {
                                Button(action: {
                                    showPDFPreview = true
                                }) {
                                    Text("Read")
                                        //.font(.headline)
                                        .font(.robotoMedium(size: 18))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(red: 241/255, green: 95/255, blue: 44/255))
                                        .cornerRadius(12)
                                }
                                .padding(.top, 8)
                            } else {
                                Button(action: {
                                    downloadPDF(from: book.pdfUrl)
                                }) {
                                    Text("Download")
                                        //.font(.headline)
                                        .font(.robotoMedium(size: 18))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(red: 241/255, green: 95/255, blue: 44/255))
                                        .cornerRadius(12)
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text(book.description)
                            .font(.body)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Your Book")
        .background(Color(red: 250/255, green: 245/255, blue: 230/255))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchBook(bookId: bookId)
        }
        .sheet(isPresented: $showPDFPreview) {
            if let fileToPreview = fileToPreview {
                PDFKitView(fileURL: fileToPreview)
            } else {
                Text("No file to preview")
            }
        }
    }
    
    private func downloadPDF(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        let session = URLSession(configuration: .default, delegate: DownloadDelegate(progressHandler: { progress in
            DispatchQueue.main.async {
                self.downloadProgress = progress
            }
        }, completionHandler: { fileURL in
            DispatchQueue.main.async {
                self.isDownloading = false
                self.isDownloaded = true
                self.fileToPreview = fileURL
            }
        }, errorHandler: { error in
            DispatchQueue.main.async {
                self.isDownloading = false
                print("Error downloading PDF: \(error.localizedDescription)")
            }
        }), delegateQueue: .main)
        
        isDownloading = true
        downloadProgress = 0.0
        
        let task = session.downloadTask(with: url)
        task.resume()
    }
}


struct PDFKitView: UIViewRepresentable {
    let fileURL: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        
        print("Trying to load PDF from: \(fileURL.path)")
        
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        print("File exists at \(fileURL.path): \(fileExists)")
        guard fileExists else {
            print("Error: File does not exist at path: \(fileURL.path)")
            return pdfView
        }
        
        if let document = PDFDocument(url: fileURL) {
            print("PDFKit successfully loaded the document. Page count: \(document.pageCount)")
            pdfView.document = document
        } else {
            print("PDFKit: Failed to load PDF document from URL: \(fileURL)")
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
