import Foundation

actor VideoCache {
    static let shared = VideoCache()

    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    init() {
        let base = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("VideoCache", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        self.cacheDirectory = dir
    }

    private func sanitizedFileName(for url: URL) -> String {
        // Use a percent-encoded absolute string limited to alphanumerics to avoid filesystem issues
        let encoded = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return encoded + ".mp4"
    }

    private func destinationURL(for remoteURL: URL) -> URL {
        return cacheDirectory.appendingPathComponent(sanitizedFileName(for: remoteURL))
    }

    func localURLIfExists(for remoteURL: URL) -> URL? {
        let dest = destinationURL(for: remoteURL)
        return fileManager.fileExists(atPath: dest.path) ? dest : nil
    }

    func fetchIfNeeded(from remoteURL: URL) async -> URL? {
        if let local = localURLIfExists(for: remoteURL) {
            return local
        }
        let dest = destinationURL(for: remoteURL)
        do {
            let (tempURL, _) = try await URLSession.shared.download(from: remoteURL)
            // Replace any existing file
            try? fileManager.removeItem(at: dest)
            try fileManager.moveItem(at: tempURL, to: dest)
            return dest
        } catch {
            #if DEBUG
            print("VideoCache: failed to download video: \(remoteURL) error: \(error)")
            #endif
            return nil
        }
    }
}
