import Foundation
import Supabase

@MainActor
final class LatestBooksViewModel: ObservableObject {
  @Published var books: [Book] = []
  @Published var errorText: String?

  func loadLatest() async {
    do {
        let res: [Book] = try await SupabaseManager.shared.client
          .from("books")
          .select(BookSelect.full)
          .order("created_at", ascending: false)
          .limit(10)
          .execute()
          .value

      self.books = res
      self.errorText = nil
    } catch {
      print("Latest error:", error)
      self.errorText = error.localizedDescription
      self.books = []
    }
  }
}
