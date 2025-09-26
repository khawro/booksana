import Foundation

struct Book: Codable, Identifiable {
  let id: Int64
  let title: String
  let description: String?
  let cover: String?
  let featured: Int?
  let selected: Int?
  let extrainfo: String?
  let book_url: String?
  let category: Int64?     // <-- NAZWA i TYP zgodne z DB (int8)
  let color_hex: String?
}
