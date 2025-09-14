import Foundation
import Supabase

@MainActor
final class CategoryDetailViewModel: ObservableObject {
  @Published var books: [Book] = []
  @Published var errorText: String?

  func loadBooks(for categoryId: Int64) async {
    do {
        let res: [Book] = try await SupabaseManager.shared.client
          .from("books")
          .select(BookSelect.full)
          .eq("category", value: Int(categoryId))
          .order("created_at", ascending: false)
          .execute()
          .value

      books = res
      errorText = nil
    } catch {
      errorText = error.localizedDescription
      books = []
    }
  }
}
