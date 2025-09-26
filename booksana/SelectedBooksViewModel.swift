import Foundation
import Supabase

@MainActor
final class SelectedBooksViewModel: ObservableObject {
  @Published var books: [Book] = []
  @Published var errorText: String?

  func loadSelected() async {
    do {
        let res: [Book] = try await SupabaseManager.shared.client
          .from("books")
          .select(BookSelect.full)
          .gte("selected", value: 0)
          .order("selected", ascending: true)
          .execute()
          .value
        
      self.books = res
      self.errorText = nil
    } catch {
      print("Selected error:", error)
      self.errorText = error.localizedDescription
      self.books = []
    }
  }
}

