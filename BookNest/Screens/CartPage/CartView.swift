import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 250/255, green: 245/255, blue: 230/255)
                    .edgesIgnoringSafeArea(.all)
                
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
                            .foregroundColor(.pink)
                            .padding()
                            .background(Color(red: 250/255, green: 245/255, blue: 230/255))
                            .cornerRadius(8)
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
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Total Amount")
                                        .font(.headline)
                                    Spacer()
                                    Text("$\(viewModel.totalAmount, specifier: "%.2f")")
                                        .font(.headline)
                                }
                                HStack {
                                    Text("Books Count")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(viewModel.cartItems.count)")
                                        .font(.headline)
                                }
                                HStack {
                                    Text("Available Balance")
                                        .font(.headline)
                                    Spacer()
                                    Text("$\(viewModel.userBalance, specifier: "%.2f")")
                                        .font(.headline)
                                }
                                Divider()
                                HStack {
                                    Text("Amount Payable")
                                        .font(.headline)
                                    Spacer()
                                    Text("$\(viewModel.totalAmount, specifier: "%.2f")")
                                        .font(.headline)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
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
                                        .background(Color(red: 241/255, green: 95/255, blue: 44/255))
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
            }
            
            Text("By \(book.authorName)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
            
            HStack(spacing: 8) {
                Text("$\(book.price, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                
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
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
}
