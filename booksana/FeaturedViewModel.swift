import Foundation
import Supabase

final class FeaturedViewModel: ObservableObject {
  @Published var books: [Book] = []         // NOWE
  @Published var errorText: String?

  // ...
  @MainActor
  func loadFeaturedList(limit: Int = 3) async {
    do {
      // pobiera max 3 książki z featured=true (dopasuj nazwę kolumny jeśli inna)
      let result: [Book] = try await SupabaseManager.shared.client
        .from("books")
        .select(BookSelect.full)
        .gte("featured", value: 0)
        .order("featured", ascending: true)
        .limit(limit)
        .execute()
        .value
      self.books = result
    } catch {
      self.errorText = error.localizedDescription
      self.books = []
    }
  }
}
