import Foundation

@MainActor
class BookCache: ObservableObject {
    static let shared = BookCache()
    
    private var cachedBooks: [Int64: Book] = [:]
    
    private init() {}
    
    func cacheBook(_ book: Book) {
        cachedBooks[book.id] = book
    }
    
    func getCachedBook(_ id: Int64) -> Book? {
        return cachedBooks[id]
    }
    
    func getCachedBooks(ids: [Int64]) -> [Book] {
        return ids.compactMap { cachedBooks[$0] }
    }
    
    func removeCachedBook(_ id: Int64) {
        cachedBooks.removeValue(forKey: id)
    }
}