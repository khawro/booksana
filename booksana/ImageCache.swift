import UIKit
import CryptoKit

final actor ImageCache {
    static let shared = ImageCache()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheFolderURL: URL
    
    init() {
        let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheFolderURL = cachesURL.appendingPathComponent("BookCoversCache", isDirectory: true)
        try? fileManager.createDirectory(at: cacheFolderURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    func image(for url: URL) async -> UIImage? {
        let key = cacheKey(for: url)
        if let image = memoryCache.object(forKey: key as NSString) {
            return image
        }
        let fileURL = cacheFolderURL.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        guard let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) else { return nil }
        memoryCache.setObject(image, forKey: key as NSString)
        return image
    }
    
    func store(_ data: Data, for url: URL) async {
        let key = cacheKey(for: url)
        if let image = UIImage(data: data) {
            memoryCache.setObject(image, forKey: key as NSString)
        }
        
        let fileURL = cacheFolderURL.appendingPathComponent(key)
        try? data.write(to: fileURL, options: [.atomic])
    }
    
    func removeAll() async {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheFolderURL)
        try? fileManager.createDirectory(at: cacheFolderURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    func fetchIfNeeded(from url: URL) async -> UIImage? {
        if let cached = await image(for: url) {
            return cached
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            await store(data, for: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    private func cacheKey(for url: URL) -> String {
        if let sha = sha256(url.absoluteString) {
            return sha
        }
        return sanitizedString(url.absoluteString)
    }
    
    private func sha256(_ string: String) -> String? {
        guard let data = string.data(using: .utf8) else { return nil }
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    private func sanitizedString(_ string: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let scalars = string.unicodeScalars.map { scalar -> String in
            return allowed.contains(scalar) ? String(scalar) : "-"
        }
        return scalars.joined()
    }
}
