import Foundation

@MainActor
final class CategoryNameCache {
  static let shared = CategoryNameCache()
  private var names: [Int64: String] = [:]

  private init() {}

  func name(for id: Int64?) -> String? {
    guard let id = id else { return nil }
    return names[id]
  }

  func setName(_ name: String, for id: Int64) {
    names[id] = name
  }

  func setMany(_ categories: [Category]) {
    for cat in categories {
      names[cat.id] = cat.category_name
    }
  }
}
