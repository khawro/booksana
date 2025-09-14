import SwiftUI

struct CategorySectionView: View {
  let title: String
  let books: [Book]

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(title)
        .font(.custom("PPEditorialNew-Regular", size: 30)) 
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 8)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: 16) {
          ForEach(books, id: \.id) { book in
            BookThumbnailView(book: book)
          }
        }
        .padding([.horizontal, .bottom], 16)
      }
    }
  }
}
