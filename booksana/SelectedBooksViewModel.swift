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
          .eq("selected", value: true)
          .order("created_at", ascending: false)
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
