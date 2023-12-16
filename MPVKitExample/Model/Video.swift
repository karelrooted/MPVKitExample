import AVKit
import Foundation
import SwiftUI
import SwiftyJSON

struct Video: Identifiable, Equatable, Hashable {
    static let shortLength = 61.0


    var id: String
    var videoID: String
    var videoURL: URL?
    var title: String
    var author: String
    var length: TimeInterval
    var published: String
    var views: Int
    var description: String?
    var genre: String?
    
    var captions = [Captions]()

    // index used when in the Playlist
    var indexID: String?

    var live: Bool
    var upcoming: Bool
    var short: Bool

    var streams = [Stream]()

    var publishedAt: Date?
    var likes: Int?
    var dislikes: Int?
    var keywords = [String]()

    var related = [Self]()
    

    init(
        id: String? = nil,
        videoID: String,
        videoURL: URL? = nil,
        title: String = "",
        author: String = "",
        length: TimeInterval = .zero,
        published: String = "",
        views: Int = 0,
        description: String? = nil,
        genre: String? = nil,
        indexID: String? = nil,
        live: Bool = false,
        upcoming: Bool = false,
        short: Bool = false,
        publishedAt: Date? = nil,
        likes: Int? = nil,
        dislikes: Int? = nil,
        keywords: [String] = [],
        streams: [Stream] = [],
        related: [Self] = []
    ) {
        self.id = id ?? UUID().uuidString
        self.videoID = videoID
        self.videoURL = videoURL
        self.title = title
        self.author = author
        self.length = length
        self.published = published
        self.views = views
        self.description = description
        self.genre = genre
        self.indexID = indexID
        self.live = live
        self.upcoming = upcoming
        self.short = short
        self.publishedAt = publishedAt
        self.keywords = keywords
        self.streams = streams
        self.related = related
    }

    static func local(_ url: URL) -> Self {
        Self(
            videoID: url.absoluteString,
            streams: [.init(localURL: url)]
        )
    }

    var cacheKey: String {
        return videoID
    }

    var json: JSON {
        let dateFormatter = ISO8601DateFormatter()
        let publishedAt = self.publishedAt == nil ? "" : dateFormatter.string(from: self.publishedAt!)
        return [
            "id": id,
            "videoID": videoID,
            "videoURL": videoURL?.absoluteString ?? "",
            "title": title,
            "author": author,
            "length": length,
            "published": published,
            "views": views,
            "description": description ?? "",
            "genre": genre ?? "",
            "indexID": indexID ?? "",
            "live": live,
            "upcoming": upcoming,
            "short": short,
            "publishedAt": publishedAt
        ]
    }

    static func from(_ json: JSON) -> Self {
        let dateFormatter = ISO8601DateFormatter()

        return Self(
            id: json["id"].stringValue,
            videoID: json["videoID"].stringValue,
            videoURL: json["videoURL"].url,
            title: json["title"].stringValue,
            author: json["author"].stringValue,
            length: json["length"].doubleValue,
            published: json["published"].stringValue,
            views: json["views"].intValue,
            description: json["description"].string,
            genre: json["genre"].string,
            indexID: json["indexID"].stringValue,
            live: json["live"].boolValue,
            upcoming: json["upcoming"].boolValue,
            short: json["short"].boolValue,
            publishedAt: dateFormatter.date(from: json["publishedAt"].stringValue)
        )
    }

    var displayTitle: String {
        return localStreamFileName ?? localStream?.description ?? title

        return title
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        let videoIDIsEqual = lhs.videoID == rhs.videoID

        if lhs.indexID != "", rhs.indexID != "" {
            return videoIDIsEqual && lhs.indexID == rhs.indexID
        }

        return videoIDIsEqual
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var isLocal: Bool {
        true
    }

    var localStream: Stream? {
        guard isLocal else { return nil }
        return streams.first
    }

    var localStreamImageSystemName: String {
        guard localStream != nil else { return "" }

        if localStreamIsDirectory {
            return "folder"
        }
        if localStreamIsFile {
            return "doc"
        }

        return "globe"
    }

    var localStreamIsFile: Bool {
        guard let url = localStream?.localURL else { return false }
        return url.isFileURL
    }

    var localStreamIsRemoteURL: Bool {
        guard let url = localStream?.localURL else { return false }
        return url.isFileURL
    }

    var localStreamIsDirectory: Bool {
        guard let localStream else { return false }
        #if os(iOS)
            return DocumentsModel.shared.isDirectory(localStream.localURL)
        #else
            return false
        #endif
    }

    var remoteUrlHost: String? {
        localStreamURLComponents?.host
    }

    var localStreamFileName: String? {
        guard let path = localStream?.localURL?.lastPathComponent else { return nil }

        if let localStreamFileExtension {
            return String(path.dropLast(localStreamFileExtension.count + 1))
        }
        return String(path)
    }

    var localStreamFileExtension: String? {
        guard let path = localStreamURLComponents?.path else { return nil }
        return path.contains(".") ? path.components(separatedBy: ".").last?.uppercased() : nil
    }

    var isShareable: Bool {
        !isLocal || localStreamIsRemoteURL
    }

    private var localStreamURLComponents: URLComponents? {
        guard let localStream else { return nil }
        return URLComponents(url: localStream.localURL, resolvingAgainstBaseURL: false)
    }
}
