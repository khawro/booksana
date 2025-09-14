import SwiftUI

struct CategoryDetailView: View {
  let category: Category
  @StateObject private var vm = CategoryDetailViewModel()
  @State private var selectedBook: Book?
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          let headerBase: CGFloat = 260

          // Header image + przycisk Wstecz
          GeometryReader { geo in
            let topInset = geo.safeAreaInsets.top
            ZStack(alignment: .topLeading) {
              let minY = geo.frame(in: .global).minY
              AsyncImage(url: URL(string: category.image ?? "")) { phase in
                switch phase {
                case .success(let image):
                  image.resizable().scaledToFill()
                default:
                  Color.gray.opacity(0.25)
                }
              }
              .frame(width: geo.size.width, height: minY > 0 ? headerBase + minY : headerBase)
              .clipped()
              .offset(y: minY > 0 ? -minY : 0)
              
            ///button hidden
                
              Button {
                dismiss()
              } label: {
                Image(systemName: "chevron.left")
                  .font(.headline.weight(.semibold))
                  .padding(10)
                  .background(.ultraThinMaterial, in: Circle())
              }
              .padding(.leading, 24)
              .padding(.top, topInset + 52)
              .opacity(0)
            }
          }
          .frame(height: headerBase)
         

          // Tytuł + opis
          VStack(alignment: .leading, spacing: 8) {
            Text(category.category_name)
              .font(.custom("PPEditorialNew-Regular", size: 40))
            if let desc = category.category_description, !desc.isEmpty {
              Text(desc)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
          }
          .padding(.horizontal, 16)
          .padding(.bottom, 16)
          .padding(.top, 16)

          // Lista książek (poziomo, jak na „Dla Ciebie”)
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
              ForEach(vm.books, id: \.id) { book in
                Button {
                  Haptics.tap(.soft)
                  selectedBook = book
                } label: {
                  BookThumbnailView(book: book)
                }
                .buttonStyle(.plain)
              }
            }
            .padding([.horizontal, .bottom], 16)
          }

          if let err = vm.errorText {
            Text(err).foregroundStyle(.red).font(.footnote).padding(.horizontal, 16)
          }
        }
        .padding(.bottom, 24)
      }
      .ignoresSafeArea(edges: .top)
      .sheet(item: $selectedBook) { book in
        TitlePageView(book: book)
          .presentationDragIndicator(.visible)
          .presentationCornerRadius(32)
      }
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .task { await vm.loadBooks(for: category.id) }
  }
}

#Preview {
  CategoryDetailView(category: Category(id: 2, category_name: "Psychologia", image: nil, category_description: "Opis"))
    .preferredColorScheme(.dark)
}
