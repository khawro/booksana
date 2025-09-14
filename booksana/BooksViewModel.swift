import Foundation
import Supabase

@MainActor
final class BooksViewModel: ObservableObject {
  @Published var firstTitle: String = ""
  @Published var firstCoverURL: URL?
  @Published var errorText: String?

  func loadFirstBook() async {
    do {
      // Zwraca [Book] (dekodowanie po typie po lewej)
      let books: [Book] = try await SupabaseManager.shared.client
        .from("books")
        .select("id,title,cover,created_at")
        .order("created_at", ascending: true)   // ustaw false, jeśli chcesz najnowszą
        .limit(1)
        .execute()
        .value

      if let b = books.first {
        firstTitle = b.title
        firstCoverURL = b.cover.flatMap { URL(string: $0) }
        errorText = nil
      } else {
        firstTitle = "Brak danych"
        firstCoverURL = nil
        errorText = nil
      }
    } catch {
      // prosta, kompatybilna obsługa błędu
      print("Supabase error:", error)
      firstTitle = "Błąd pobierania"
      firstCoverURL = nil
      errorText = error.localizedDescription
    }
  }
}
