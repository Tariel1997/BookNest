import SwiftUI
import PDFKit

struct BookDetailView: View {
    @StateObject private var viewModel = BookDetailViewModel()
    let bookId: String
    
    @State private var fileToPreview: URL? = nil
    @State private var showPDFPreview = false
    
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
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("Category: \(book.genres.joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("Rating: \(String(format: "%.2f", book.rating)) / 5")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                            
                            Text("Pricing: \(String(format: "$%.2f", book.price))")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Button(action: {
                                downloadPDF(from: book.pdfUrl) { fileURL in
                                    DispatchQueue.main.async {
                                        guard let fileURL = fileURL else {
                                            print("Error: fileURL is nil after download.")
                                            return
                                        }
                                        self.fileToPreview = fileURL
                                        self.showPDFPreview = true
                                        print("File to preview set and showPDFPreview updated: \(fileURL.path)")
                                    }
                                }
                            }) {
                                Text("Download")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 241/255, green: 95/255, blue: 44/255))
                                    .cornerRadius(12)
                            }
                            .padding(.top, 8)
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
        .onChange(of: fileToPreview) { newValue in
            if newValue != nil {
                showPDFPreview = true
                print("File to preview changed: \(newValue?.path ?? "nil"), opening sheet.")
            } else {
                print("File to preview is nil.")
            }
        }
        .sheet(isPresented: $showPDFPreview) {
            Group {
                if let fileToPreview = fileToPreview {
                    PDFKitView(fileURL: fileToPreview)
                        .onAppear {
                            print("Opening PDFKitView with fileURL: \(fileToPreview.path)")
                        }
                } else {
                    Text("No file to preview")
                        .onAppear {
                            print("Error: No fileToPreview is set.")
                        }
                }
            }
        }
    }
    
    private func downloadPDF(from urlString: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let localURL = localURL else {
                print("No file found at URL.")
                completion(nil)
                return
            }
            
            do {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
                
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                
                let data = try Data(contentsOf: destinationURL)
                print("File successfully saved to: \(destinationURL), size: \(data.count) bytes")
                
                if data.count == 0 {
                    print("Downloaded file is empty.")
                    completion(nil)
                    return
                }
                
                completion(destinationURL)
            } catch {
                print("Error saving file: \(error.localizedDescription)")
                completion(nil)
            }
        }
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
