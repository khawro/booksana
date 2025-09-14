import SwiftUI

struct CategoryCardView: View {
  let category: Category

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      AsyncImage(url: URL(string: category.image ?? "")) { phase in
        switch phase {
        case .success(let image):
          image.resizable().scaledToFill()
        default:
          RoundedRectangle(cornerRadius: 22)
            .fill(Color.gray.opacity(0.25))
        }
      }
      .frame(width: 160, height: 120)
      .clipped()
      .clipShape(RoundedRectangle(cornerRadius: 18))

      // overlay: gradient + tytuł
      LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.55)],
                     startPoint: .center, endPoint: .bottom)
        .clipShape(RoundedRectangle(cornerRadius: 18))

      Text(category.category_name)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.white)
        .shadow(radius: 3)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }
    .frame(width: 160, height: 120, alignment: .bottomLeading)
  }
}
