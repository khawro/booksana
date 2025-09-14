import SwiftUI

struct SavedView: View {
  var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        Image(systemName: "bookmark")
          .font(.system(size: 60))
          .fontWeight(.thin)
          .opacity(0.5)
        Text("Brak zapisanych")
          .font(.custom("PPEditorialNew-Regular", size: 30))
        Text("Tutaj pojawią się Twoje zapisane rozdziały oraz książki.")
          .font(.subheadline)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      .padding(.horizontal)
    }
  }
}

#Preview {
  SavedView().preferredColorScheme(.dark)
}
