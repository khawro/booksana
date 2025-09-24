import Foundation

final class LastReadPositionStore {
    static let shared = LastReadPositionStore()
    private let defaults: UserDefaults
    private init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    private func key(for bookID: Int64) -> String { "lastSlideIndex.\(bookID)" }

    func lastSlideIndex(for bookID: Int64) -> Int? {
        let k = key(for: bookID)
        if defaults.object(forKey: k) == nil { return nil }
        let value = defaults.integer(forKey: k)
        return value
    }

    func setLastSlideIndex(_ index: Int, for bookID: Int64) {
        defaults.set(index, forKey: key(for: bookID))
    }

    func clearLastSlideIndex(for bookID: Int64) {
        defaults.removeObject(forKey: key(for: bookID))
    }

    func clearAll() {
        // This is safe because we namespace keys with a prefix
        let prefix = "lastSlideIndex."
        for (key, _) in defaults.dictionaryRepresentation() {
            if key.hasPrefix(prefix) { defaults.removeObject(forKey: key) }
        }
    }
}
