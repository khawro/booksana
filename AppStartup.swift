import Foundation

final class AppStartup {
    static let shared = AppStartup()
    
    private let hasPrefetchedKey = "AppStartup.hasPrefetchedAssets"
    
    private init() {}
    
    func prefetchIfNeeded(books: [Book], categories: [Category]) async {
        if UserDefaults.standard.bool(forKey: hasPrefetchedKey) {
            return
        }
        
        // Deduplicate books by id, then collect valid cover URLs
        var seenBookIDs = Set<Int64>()
        var uniqueBookURLs: [URL] = []
        for book in books {
            guard !seenBookIDs.contains(book.id) else { continue }
            seenBookIDs.insert(book.id)
            if let cover = book.cover, let url = URL(string: cover) {
                uniqueBookURLs.append(url)
            }
        }
        
        let categoryURLs = categories.compactMap { category -> URL? in
            guard let image = category.image else { return nil }
            return URL(string: image)
        }
        
        let allURLs = uniqueBookURLs + categoryURLs
        
        if allURLs.isEmpty {
            UserDefaults.standard.set(true, forKey: hasPrefetchedKey)
            return
        }
        
        await withTaskGroup(of: Void.self) { group in
            for url in allURLs {
                group.addTask {
                    await ImageCache.shared.fetchIfNeeded(from: url)
                }
            }
        }
        
        // Warm the memory cache so first render is instant in UI
        await withTaskGroup(of: Void.self) { group in
            for url in allURLs {
                group.addTask {
                    _ = await ImageCache.shared.image(for: url)
                }
            }
        }
        
        UserDefaults.standard.set(true, forKey: hasPrefetchedKey)
    }
}

