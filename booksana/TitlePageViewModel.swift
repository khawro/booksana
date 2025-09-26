import Foundation
import Supabase

@MainActor
final class TitlePageViewModel: ObservableObject {
  @Published var categoryName: String? = nil
  @Published var isLoading = false
  @Published var lastError: String? = nil

  func loadCategoryName(for categoryId: Int64?) async {
    // 1) Upewnij się, że mamy ID
    guard let rawId = categoryId else {
      self.categoryName = nil
      self.lastError = "Brak categoryId w Book"
      return
    }
    let id = Int(rawId) // int8 -> Int

    // Fast path: try cache first
    if let cached = CategoryNameCache.shared.name(for: rawId) {
      self.categoryName = cached
      self.lastError = nil
      return
    }

    isLoading = true
    defer { isLoading = false }

    do {
      struct Row: Decodable { let category_name: String }

      // 2) Pobierz tablicę i weź pierwszy wiersz
      let rows: [Row] = try await SupabaseManager.shared.client
        .from("categories")
        .select("category_name")
        .eq("id", value: id)
        .limit(1)
        .execute()
        .value

      if let name = rows.first?.category_name, !name.isEmpty {
        self.categoryName = name
        self.lastError = nil
        CategoryNameCache.shared.setName(name, for: rawId)
      } else {
        self.categoryName = nil
        self.lastError = "Brak kategorii dla id \(id)"
      }
    } catch {
      self.categoryName = nil
      self.lastError = error.localizedDescription
      print("TitlePageViewModel error:", error)
    }
  }
}

