import Foundation
import Supabase

@MainActor
final class FeaturedViewModel: ObservableObject {
  @Published var book: Book?
  @Published var errorText: String?

  func loadFeatured() async {
    do {
        let res: [Book] = try await SupabaseManager.shared.client
          .from("books")
          .select(BookSelect.full)
          .eq("featured", value: true)
          .order("created_at", ascending: false)
          .limit(1)
          .execute()
          .value
        
      self.book = res.first
      self.errorText = nil
    } catch {
      print("Featured error:", error)
      self.errorText = error.localizedDescription
      self.book = nil
    }
  }
}



