import Foundation
import Supabase

enum Secrets {
  // Wstaw dane z Supabase -> Project Settings -> API
  static let url = URL(string: "https://jqydzrplreedenqfwbik.supabase.co")!
  static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxeWR6cnBscmVlZGVucWZ3YmlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3NTYwNDcsImV4cCI6MjA3MzMzMjA0N30.xDtUWIdPYOkFFmJufD-Jw0bh2Z6y9jOAuUFziaewyic"
}

enum BookSelect {
  static let full = "id,title,description,cover,extrainfo,book_url,category,color_hex,created_at,featured,selected"
}

final class SupabaseManager {
  static let shared = SupabaseManager()

  let client: SupabaseClient

  private init() {
    client = SupabaseClient(
      supabaseURL: Secrets.url,
      supabaseKey: Secrets.anonKey
    )
  }
}
