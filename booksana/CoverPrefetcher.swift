import Foundation

struct CoverPrefetcher {
    static let shared = CoverPrefetcher()
    private let hasPrefetchedKey = "hasPrefetchedCovers"
    
    func prefetchIfNeeded(books: [Book]) async {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: hasPrefetchedKey) else { return }
        
        let urls = books.compactMap { book -> URL? in
            guard let cover = book.cover else { return nil }
            return URL(string: cover)
        }
        
        guard !urls.isEmpty else { return }
        
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for url in urls {
                    group.addTask {
                        _ = await ImageCache.shared.fetchIfNeeded(from: url)
                    }
                }
                try await group.waitForAll()
            }
            defaults.set(true, forKey: hasPrefetchedKey)
        } catch {
            // Handle errors or cancellation gracefully by not setting the flag
        }
    }
}
