import SwiftUI

struct BooksView: View {
    @StateObject private var viewModel = BooksViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 250/255, green: 245/255, blue: 230/255)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Loading books...")
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if viewModel.userBooks.isEmpty {
                        Text("No books purchased yet.")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(viewModel.userBooks, id: \.title) { book in
                                    NavigationLink(destination: BookDetailView(bookId: book.title)) {
                                        BookItemView(book: book)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .navigationTitle("Your Books")
                .background(Color(red: 250/255, green: 245/255, blue: 230/255))
                .onAppear {
                    viewModel.fetchUserBooks()
                }
            }
        }
    }
    
}

struct BookItemView: View {
    let book: Book
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: book.imageUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
                } else if phase.error != nil {
                    Color.red
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
                } else {
                    Color.gray.opacity(0.3)
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(book.authorName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Rating: \(String(format: "%.1f", book.rating))")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                
                HStack {
                    ForEach(book.genres, id: \.self) { genre in
                        Text(genre)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
}
