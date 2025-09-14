import Foundation

struct Category: Codable, Identifiable {
  let id: Int64
  let category_name: String
  let image: String?
  let category_description: String?   
}
