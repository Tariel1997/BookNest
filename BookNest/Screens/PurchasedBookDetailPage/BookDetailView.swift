import SwiftUI
import PDFKit

struct BookDetailView: View {
    @StateObject private var viewModel = BookDetailViewModel()
    let bookId: String
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(errorMessage: errorMessage)
            } else if let book = viewModel.book {
                VStack(alignment: .leading, spacing: 16) {
                    titleView(book: book)
                    bookInfoView(book: book)
                    descriptionView(book: book)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Your Book")
        .background(isDarkMode ? Color.black : Color(red: 250 / 255, green: 245 / 255, blue: 230 / 255))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchBook(bookId: bookId)
        }
        .sheet(isPresented: $viewModel.showPDFPreview) {
            if let fileToPreview = viewModel.fileToPreview {
                PDFKitView(fileURL: fileToPreview)
            } else {
                Text("No file to preview")
                    .foregroundColor(isDarkMode ? .white : .black)
            }
        }
    }
    
    
    @ViewBuilder
    private var loadingView: some View {
        ProgressView("Loading book details...")
    }
    
    @ViewBuilder
    private func errorView(errorMessage: String) -> some View {
        Text(errorMessage)
            .foregroundColor(isDarkMode ? .red.opacity(0.7) : .red)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    @ViewBuilder
    private func titleView(book: Book) -> some View {
        HStack {
            Spacer()
            Text(book.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.vertical)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func bookInfoView(book: Book) -> some View {
        HStack(alignment: .top, spacing: 16) {
            bookImageView(url: book.imageUrl)
            bookDetailsView(book: book)
        }
    }
    
    @ViewBuilder
    private func bookImageView(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
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
    }
    
    @ViewBuilder
    private func bookDetailsView(book: Book) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Author: \(book.authorName)")
                .font(.inter(size: 16))
                .foregroundColor(isDarkMode ? .gray.opacity(0.7) : .gray)
            Text("Category: \(book.genres.joined(separator: ", "))")
                .font(.roboto(size: 16))
                .foregroundColor(isDarkMode ? .gray.opacity(0.7) : .gray)
            Text("Rating: \(String(format: "%.2f", book.rating)) / 5")
                .font(.robotoMedium(size: 16))
                .foregroundColor(isDarkMode ? .yellow : .orange)
            Text("Pricing: \(String(format: "$%.2f", book.price))")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
            
            if viewModel.isDownloading {
                downloadProgressView
            } else if viewModel.isDownloaded {
                readButton
            } else {
                downloadButton(book: book)
            }
        }
    }
    
    @ViewBuilder
    private func descriptionView(book: Book) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description:")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.horizontal)
            Text(book.description)
                .font(.body)
                .foregroundColor(isDarkMode ? .gray.opacity(0.7) : .gray)
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var downloadProgressView: some View {
        VStack {
            Text("Downloading...")
                .foregroundColor(isDarkMode ? .white : .black)
            ProgressView(value: viewModel.downloadProgress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.top, 8)
        }
    }
    
    @ViewBuilder
    private var readButton: some View {
        Button(action: {
            viewModel.showPDFPreview = true
        }) {
            Text("Read")
                .font(.robotoMedium(size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDarkMode ? Color(red: 241/255, green: 95/255, blue: 44/255) : Color(red: 241/255, green: 95/255, blue: 44/255))
                .cornerRadius(12)
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func downloadButton(book: Book) -> some View {
        Button(action: {
            viewModel.downloadPDF(from: book.pdfUrl)
        }) {
            Text("Download")
                .font(.robotoMedium(size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDarkMode ? Color(red: 241/255, green: 95/255, blue: 44/255) : Color(red: 241/255, green: 95/255, blue: 44/255))
                .cornerRadius(12)
        }
        .padding(.top, 8)
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
