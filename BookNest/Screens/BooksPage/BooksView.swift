import SwiftUI

struct BooksView: View {
    @StateObject private var viewModel = BooksViewModel()
    
    var body: some View {
        NavigationView {
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
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(viewModel.userBooks, id: \.title) { book in
                                BookItemView(book: book)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("My Books")
            .onAppear {
                viewModel.fetchUserBooks()
            }
        }
    }
}

struct BookItemView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: book.imageUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 200)
                        .cornerRadius(8)
                } else if phase.error != nil {
                    Color.red
                        .frame(width: 160, height: 200)
                        .cornerRadius(8)
                } else {
                    Color.gray.opacity(0.3)
                        .frame(width: 160, height: 200)
                        .cornerRadius(8)
                }
            }
            
            Text(book.title)
                .font(.headline)
                .lineLimit(2)
            
            Text("\(book.authorName)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
}
