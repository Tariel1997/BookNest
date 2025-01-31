import SwiftUI

struct BooksView: View {
    @StateObject private var viewModel = BooksViewModel()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
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
                .background(isDarkMode ? Color.black : Color(red: 250/255, green: 245/255, blue: 230/255))
                .onAppear {
                    viewModel.fetchUserBooks()
                }
            }
        }
    }
    
}
