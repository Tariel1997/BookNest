import SwiftUI

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
                    .foregroundColor(isDarkMode ? .gray.opacity(0.7) : .gray)
                
                Text("Rating: \(String(format: "%.1f", book.rating))")
                    .font(.subheadline)
                    .foregroundColor(isDarkMode ? .yellow : .orange)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack (spacing: 5) {
                        ForEach(book.genres, id: \.self) { genre in
                            Text(genre)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(isDarkMode ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
                                .foregroundColor(isDarkMode ? .white : .black)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
        .cornerRadius(12)
        .shadow(color: isDarkMode ? Color.black.opacity(0.5) : Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
}
