import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                (isDarkMode ? Color.black : Color(red: 250/255, green: 245/255, blue: 230/255))
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Loading your cart...")
                            .padding()
                            .foregroundColor(isDarkMode ? .white : .black)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if viewModel.cartItems.isEmpty {
                        Text("Your cart is empty.")
                            .font(.title3)
                            .foregroundColor(isDarkMode ? .white : .gray)
                            .padding()
                            .background(isDarkMode ? Color.gray.opacity(0.2) : Color(red: 250/255, green: 245/255, blue: 230/255))
                            .cornerRadius(8)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 16) {
                                ForEach(viewModel.cartItems, id: \.title) { book in
                                    CartItemView(book: book, onDelete: {
                                        viewModel.deleteBookFromCart(book: book)
                                    }, isDarkMode: isDarkMode)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 80)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Total Amount")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Text("$\(viewModel.totalAmount, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                }
                                HStack {
                                    Text("Books Count")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Text("\(viewModel.cartItems.count)")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                }
                                HStack {
                                    Text("Available Balance")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Text("$\(viewModel.userBalance, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                }
                                Divider()
                                    .background(isDarkMode ? Color.white : Color.gray)
                                HStack {
                                    Text("Amount Payable")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Text("$\(viewModel.totalAmount, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                }
                            }
                            .padding()
                            .background(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
                            .cornerRadius(12)
                            .shadow(color: isDarkMode ? Color.clear : Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                            .padding(.horizontal)
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    viewModel.checkOut { message in
                                        DispatchQueue.main.async {
                                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                               let rootViewController = windowScene.windows.first?.rootViewController {
                                                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: .default))
                                                rootViewController.present(alert, animated: true, completion: nil)
                                            }
                                        }
                                    }
                                }) {
                                    Text("Check-Out")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(isDarkMode ? Color(red: 241/255, green: 95/255, blue: 44/255) : Color(red: 241/255, green: 95/255, blue: 44/255))
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
            .navigationBarTitle("Cart", displayMode: .inline)
        }
        .onAppear {
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
    let isDarkMode: Bool
    
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
                    .foregroundColor(isDarkMode ? .white : .black)
                    .lineLimit(2)
            }
            
            Text("By \(book.authorName)")
                .font(.subheadline)
                .foregroundColor(isDarkMode ? .white : .gray)
                .lineLimit(1)
            
            HStack(spacing: 8) {
                Text("$\(book.price, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isDarkMode ? .white : .black)
                
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
        }
        .padding()
        .background(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
        .cornerRadius(12)
        .shadow(color: isDarkMode ? Color.clear : Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
}
