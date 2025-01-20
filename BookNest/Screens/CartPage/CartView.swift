import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading your cart...")
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if viewModel.cartItems.isEmpty {
                Text("Your cart is empty.")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.cartItems, id: \.title) { book in
                            CartItemView(book: book) {
                                viewModel.deleteBookFromCart(book: book)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle("Cart")
        .background(Color(red: 250/255, green: 245/255, blue: 230/255))
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            print("CartView appeared. Fetching cart items...")
            viewModel.startListeningForCartItems()
        }
        .onDisappear {
            viewModel.stopListeningForCartItems()
        }
    }
}

struct CartItemView: View {
    let book: Book
    let onDelete: () -> Void
    
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
            
            HStack {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .frame(width: 15, height: 15)
            }
            
            Text("By \(book.authorName)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
            
            HStack(spacing: 8) {
                Text("$\(book.price, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Button(action: {}) {
                    Text("Buy")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .background(Color(red: 241/255, green: 95/255, blue: 44/255))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
}
