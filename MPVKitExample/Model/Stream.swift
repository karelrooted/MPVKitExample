import AVFoundation
import Defaults
import Foundation

// swiftlint:disable:next final_class
class Stream: Equatable, Hashable, Identifiable {
    enum Resolution: String, CaseIterable, Comparable, Defaults.Serializable {
        case hd2160p60
        case hd2160p50
        case hd2160p48
        case hd2160p30
        case hd1440p60
        case hd1440p50
        case hd1440p48
        case hd1440p30
        case hd1080p60
        case hd1080p50
        case hd1080p48
        case hd1080p30
        case hd720p60
        case hd720p50
        case hd720p48
        case hd720p30
        case sd480p30
        case sd360p30
        case sd240p30
        case sd144p30
        case unknown

        var name: String {
            "\(height)p\(refreshRate != -1 && refreshRate != 30 ? ", \(refreshRate) fps" : "")"
        }

        var height: Int {
            if self == .unknown {
                return -1
            }

            let resolutionPart = rawValue.components(separatedBy: "p").first!
            return Int(resolutionPart.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
        }

        var refreshRate: Int {
            if self == .unknown {
                return -1
            }

            let refreshRatePart = rawValue.components(separatedBy: "p")[1]

            if refreshRatePart.isEmpty {
                return 30
            }

            return Int(refreshRatePart.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? -1
        }

        static func from(resolution: String, fps: Int? = nil) -> Self {
            allCases.first { $0.rawValue.contains(resolution) && $0.refreshRate == (fps ?? 30) } ?? .unknown
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.height == rhs.height ? (lhs.refreshRate < rhs.refreshRate) : (lhs.height < rhs.height)
        }
    }

    enum Kind: String, Comparable {
        case stream, adaptive, hls

        private var sortOrder: Int {
            switch self {
            case .hls:
                return 0
            case .stream:
                return 1
            case .adaptive:
                return 2
            }
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.sortOrder < rhs.sortOrder
        }
    }

    enum Format: String, Comparable {
        case webm
        case avc1
        case av1
        case mp4
        case unknown

        private var sortOrder: Int {
            switch self {
            case .mp4:
                return 0
            case .avc1:
                return 1
            case .av1:
                return 2
            case .webm:
                return 3
            case .unknown:
                return 4
            }
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.sortOrder < rhs.sortOrder
        }

        var description: String {
            switch self {
            case .webm:
                return "WebM"

            default:
                return rawValue.uppercased()
            }
        }

        static func from(_ string: String) -> Self {
            let lowercased = string.lowercased()

            if lowercased.contains("webm") {
                return .webm
            }
            if lowercased.contains("avc1") {
                return .avc1
            }
            if lowercased.contains("av01") {
                return .av1
            }
            if lowercased.contains("mpeg_4") || lowercased.contains("mp4") {
                return .mp4
            }
            return .unknown
        }
    }

    let id = UUID()

    var audioAsset: AVURLAsset!
    var videoAsset: AVURLAsset!
    var hlsURL: URL!
    var localURL: URL!

    var resolution: Resolution!
    var kind: Kind!
    var format: Format!

    var encoding: String?
    var videoFormat: String?

    init(
        audioAsset: AVURLAsset? = nil,
        videoAsset: AVURLAsset? = nil,
        hlsURL: URL? = nil,
        localURL: URL? = nil,
        resolution: Resolution? = nil,
        kind: Kind = .hls,
        encoding: String? = nil,
        videoFormat: String? = nil
    ) {
        self.audioAsset = audioAsset
        self.videoAsset = videoAsset
        self.hlsURL = hlsURL
        self.localURL = localURL
        self.resolution = resolution
        self.kind = kind
        self.encoding = encoding
        format = .from(videoFormat ?? "")
    }

    var isLocal: Bool {
        localURL != nil
    }

    var isHLS: Bool {
        hlsURL != nil
    }

    var quality: String {
        return "Opened File"
        return kind == .hls ? "adaptive (HLS)" : "\(resolution.name)\(kind == .stream ? " (\(kind.rawValue))" : "")"
    }

    var shortQuality: String {
        return "File"

        if kind == .hls {
            return "HLS"
        }
        return resolution?.name ?? "?"
    }

    var description: String {
        return resolutionAndFormat
        return "\(resolutionAndFormat)"
    }

    var resolutionAndFormat: String {
        let formatString = format == .unknown ? "" : " (\(format.description))"
        return "\(quality)\(formatString)"
    }

    var assets: [AVURLAsset] {
        [audioAsset, videoAsset]
    }

    var videoAssetContainsAudio: Bool {
        assets.dropFirst().allSatisfy { $0.url == assets.first!.url }
    }

    var singleAssetURL: URL? {
        return localURL

        if kind == .hls {
            return hlsURL
        }
        if videoAssetContainsAudio {
            return videoAsset.url
        }

        return nil
    }

    static func == (lhs: Stream, rhs: Stream) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        if let url = videoAsset?.url {
            hasher.combine(url)
        }
        if let url = audioAsset?.url {
            hasher.combine(url)
        }
        if let url = hlsURL {
            hasher.combine(url)
        }
    }
}
