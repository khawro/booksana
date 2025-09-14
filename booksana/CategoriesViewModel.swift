import Foundation
import Supabase

@MainActor
final class CategoriesViewModel: ObservableObject {
  @Published var categories: [Category] = []
  @Published var booksByCategory: [Int64: [Book]] = [:]
  @Published var errorText: String?

  func loadAll() async {
    do {
      // 1) kategorie
      let cats: [Category] = try await SupabaseManager.shared.client
        .from("categories")
        .select("id,category_name,image,category_description,created_at")
        .order("created_at", ascending: true)
        .execute()
        .value

      self.categories = cats

      // 2) książki per kategoria (prosto, sekwencyjnie)
      var map: [Int64: [Book]] = [:]

      for cat in cats {
        let books: [Book] = try await SupabaseManager.shared.client
          .from("books")
          .select(BookSelect.full)  // nie musisz wybierać category_id
          .eq("category", value: Int(cat.id)) // <-- kluczowa poprawka: Int zamiast Int64
          .order("created_at", ascending: false)
          .limit(10)
          .execute()
          .value

        map[cat.id] = books
      }

      self.booksByCategory = map
      self.errorText = nil

    } catch {
      print("Categories error:", error)
      self.errorText = error.localizedDescription
    }
  }
}
