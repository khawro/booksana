import SwiftUI

/* OLD TO DELETE
 
 
struct ContentView: View {
  @StateObject private var featuredVM = FeaturedViewModel()
    
 

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {

          Text("Dla Ciebie")
            .font(.custom("PPEditorialNew-Regular", size: 40))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            

          Group {
            if let book = featuredVM.book {
              FeaturedHeroView(book: book)
                .padding(.horizontal)
            } else if let err = featuredVM.errorText {
              VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                Text(err).font(.footnote).multilineTextAlignment(.center)
              }
              .foregroundStyle(.red)
              .padding(.horizontal)
            } else {
              // placeholder / skeleton
              RoundedRectangle(cornerRadius: 28)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 420)
                .padding(.horizontal)
            }
          }

          // TODO: tu później dodamy sekcję „Wybrane”, listy itd.
        }
        .padding(.vertical)
      }
      .background(Color(.systemBackground))
      .task { await featuredVM.loadFeatured() }
    }
  }
}




#Preview {
    ContentView()
}
 */
