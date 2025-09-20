import Foundation

struct BookmarkEntry: Codable {
    let bookId: Int64
    let bookmarkedAt: Date
}

@MainActor
class SavedBooksManager: ObservableObject {
    static let shared = SavedBooksManager()
    
    @Published var savedBookIds: Set<Int64> = []
    @Published var savedBooks: [Book] = []
    @Published var isLoading: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let savedBooksKey = "saved_books_with_timestamps"
    
    init() {
        loadSavedBookIds()
    }
    
    // MARK: - Public Methods
    
    func isBookmarked(_ bookId: Int64) -> Bool {
        return savedBookIds.contains(bookId)
    }
    
    func toggleBookmark(for book: Book) -> Bool {
        if savedBookIds.contains(book.id) {
            removeBookmark(book.id)
            return false
        } else {
            addBookmark(for: book)
            return true
        }
    }
    
    func addBookmark(for book: Book) {
        let bookmark = BookmarkEntry(bookId: book.id, bookmarkedAt: Date())
        var bookmarks = loadBookmarks()
        bookmarks.append(bookmark)
        saveBookmarks(bookmarks)
        savedBookIds.insert(book.id)
        
        // Cache the book
        BookCache.shared.cacheBook(book)
        
        // Add the book to our saved books if not already there
        if !savedBooks.contains(where: { $0.id == book.id }) {
            savedBooks.append(book)
            sortSavedBooks()
        }
    }
    
    func removeBookmark(_ bookId: Int64) {
        var bookmarks = loadBookmarks()
        bookmarks.removeAll { $0.bookId == bookId }
        saveBookmarks(bookmarks)
        savedBookIds.remove(bookId)
        
        // Remove from saved books and cache
        savedBooks.removeAll { $0.id == bookId }
        BookCache.shared.removeCachedBook(bookId)
    }
    
    func loadSavedBooks() async {
        isLoading = true
        
        let bookmarks = loadBookmarks()
        savedBookIds = Set(bookmarks.map { $0.bookId })
        
        // Load books from cache
        let bookmarkIds = bookmarks.map { $0.bookId }
        savedBooks = BookCache.shared.getCachedBooks(ids: bookmarkIds)
        
        sortSavedBooks()
        
        isLoading = false
    }
    
    func refreshSavedBooks() async {
        await loadSavedBooks()
    }
    
    // MARK: - Private Methods
    
    private func loadSavedBookIds() {
        let bookmarks = loadBookmarks()
        savedBookIds = Set(bookmarks.map { $0.bookId })
    }
    
    private func loadBookmarks() -> [BookmarkEntry] {
        guard let data = userDefaults.data(forKey: savedBooksKey),
              let bookmarks = try? JSONDecoder().decode([BookmarkEntry].self, from: data) else {
            return []
        }
        return bookmarks
    }
    
    private func saveBookmarks(_ bookmarks: [BookmarkEntry]) {
        if let data = try? JSONEncoder().encode(bookmarks) {
            userDefaults.set(data, forKey: savedBooksKey)
        }
    }
    
    private func sortSavedBooks() {
        let bookmarks = loadBookmarks()
        let bookmarkDict = Dictionary(uniqueKeysWithValues: bookmarks.map { ($0.bookId, $0.bookmarkedAt) })
        
        savedBooks.sort { book1, book2 in
            let date1 = bookmarkDict[book1.id] ?? Date.distantPast
            let date2 = bookmarkDict[book2.id] ?? Date.distantPast
            return date1 > date2 // Most recent first
        }
    }
}
