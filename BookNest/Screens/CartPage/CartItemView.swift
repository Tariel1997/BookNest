import SwiftUI

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

