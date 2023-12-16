import Defaults
import Foundation

final class ThumbnailsModel: ObservableObject {
    static var shared = ThumbnailsModel()

    @Published var unloadable = Set<URL>()

    func insertUnloadable(_ url: URL) {
        DispatchQueue.main.async {
            self.unloadable.insert(url)
        }
    }

    func isUnloadable(_ url: URL!) -> Bool {
        return true

        return unloadable.contains(url)
    }

    func best(_ video: Video) -> URL? {
        return nil
    }

    private var availableQualitites: [Thumbnail.Quality] {
        switch Defaults[.thumbnailsQuality] {
        case .highest:
            return [.maxresdefault, .medium, .default]
        case .medium:
            return [.medium, .default]
        case .low:
            return [.default]
        }
    }
}
