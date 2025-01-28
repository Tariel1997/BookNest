import SwiftUI

struct BooksView: View {
    @StateObject private var viewModel = BooksViewModel()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                //Color(red: 250/255, green: 245/255, blue: 230/255)
                (isDarkMode ? Color.black : Color(red: 250/255, green: 245/255, blue: 230/255))
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Loading books...")
                            .padding()
                            .foregroundColor(isDarkMode ? .white : .black)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if viewModel.userBooks.isEmpty {
                        Text("No books purchased yet.")
                            .font(.title3)
                            //.foregroundColor(.gray)
                            .foregroundColor(isDarkMode ? .white : .gray)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(viewModel.userBooks, id: \.title) { book in
                                    NavigationLink(destination: BookDetailView(bookId: book.title)) {
                                        BookItemView(book: book, isDarkMode: isDarkMode)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .navigationTitle("Your Books")
                .foregroundColor(isDarkMode ? .white : .black)
                //.background(Color(red: 250/255, green: 245/255, blue: 230/255))
                .background(isDarkMode ? Color.black : Color(red: 250/255, green: 245/255, blue: 230/255))
                .onAppear {
                    viewModel.fetchUserBooks()
                }
            }
        }
    }
    
}

struct BookItemView: View {
    let book: Book
    let isDarkMode: Bool
    
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
                    .foregroundColor(isDarkMode ? .white : .black)
                    .lineLimit(2)
                
                Text(book.authorName)
                    .font(.subheadline)
                    //.foregroundColor(.gray)
                    .foregroundColor(isDarkMode ? .gray.opacity(0.7) : .gray)
                
                Text("Rating: \(String(format: "%.1f", book.rating))")
                    .font(.subheadline)
                    //.foregroundColor(.orange)
                    .foregroundColor(isDarkMode ? .yellow : .orange)
                
                HStack {
                    ForEach(book.genres, id: \.self) { genre in
                        Text(genre)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            //.background(Color.gray.opacity(0.2))
                            .background(isDarkMode ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
                            .foregroundColor(isDarkMode ? .white : .black)
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        //.background(Color.white)
        .background(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
        .cornerRadius(12)
        //.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
        .shadow(color: isDarkMode ? Color.black.opacity(0.5) : Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
}
