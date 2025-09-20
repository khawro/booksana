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
    
    func store(_ image: UIImage, for url: URL) async {
        let key = cacheKey(for: url)
        memoryCache.setObject(image, forKey: key as NSString)
        
        let fileURL = cacheFolderURL.appendingPathComponent(key)
        // Downscale if needed before saving
        let imageToSave = image.downscaledIfNeeded(maxDimension: 1024)
        guard let pngData = imageToSave.pngDataOrNil else { return }
        try? pngData.write(to: fileURL, options: [.atomic])
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
            guard let image = UIImage(data: data) else { return nil }
            await store(image, for: url)
            return image
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

private extension UIImage {
    var pngDataOrNil: Data? {
        self.pngData()
    }
    
    func downscaledIfNeeded(maxDimension: CGFloat) -> UIImage {
        let maxCurrentDimension = max(size.width, size.height)
        guard maxCurrentDimension > maxDimension else {
            return self
        }
        let scale = maxDimension / maxCurrentDimension
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
