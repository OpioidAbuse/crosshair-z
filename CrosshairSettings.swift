import Cocoa

extension Notification.Name {
    static let crosshairSettingsChanged = Notification.Name("crosshairSettingsChanged")
}

enum CrosshairStyle: Int, CaseIterable {
    case cross = 0
    case dot = 1
    case circle = 2
    case crossDot = 3
    case customImage = 4

    var displayName: String {
        switch self {
        case .cross: return "Cross"
        case .dot: return "Dot"
        case .circle: return "Circle"
        case .crossDot: return "Cross + Dot"
        case .customImage: return "Custom Image"
        }
    }
}

/// Single source of truth for crosshair appearance. Persists to UserDefaults
/// and broadcasts a notification whenever anything changes so every window
/// (overlay + settings preview) can redraw itself.
final class CrosshairSettings {
    static let shared = CrosshairSettings()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let isVisible = "crosshair.isVisible"
        static let style = "crosshair.style"
        static let colorData = "crosshair.colorData"
        static let length = "crosshair.length"
        static let thickness = "crosshair.thickness"
        static let gap = "crosshair.gap"
        static let opacity = "crosshair.opacity"
        static let outline = "crosshair.outline"
        static let customImageData = "crosshair.customImageData"
        static let imageSize = "crosshair.imageSize"
    }

    var isVisible: Bool {
        didSet { defaults.set(isVisible, forKey: Keys.isVisible); notify() }
    }
    var style: CrosshairStyle {
        didSet { defaults.set(style.rawValue, forKey: Keys.style); notify() }
    }
    var color: NSColor {
        didSet {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
                defaults.set(data, forKey: Keys.colorData)
            }
            notify()
        }
    }
    var length: Double {
        didSet { defaults.set(length, forKey: Keys.length); notify() }
    }
    var thickness: Double {
        didSet { defaults.set(thickness, forKey: Keys.thickness); notify() }
    }
    var gap: Double {
        didSet { defaults.set(gap, forKey: Keys.gap); notify() }
    }
    var opacity: Double {
        didSet { defaults.set(opacity, forKey: Keys.opacity); notify() }
    }
    var showOutline: Bool {
        didSet { defaults.set(showOutline, forKey: Keys.outline); notify() }
    }

    /// Raw PNG bytes of a user-supplied crosshair image, if any. Stored as
    /// data (not a file path) so it survives the source file being moved or deleted.
    var customImageData: Data? {
        didSet {
            defaults.set(customImageData, forKey: Keys.customImageData)
            cachedCustomImage = customImageData.flatMap { NSImage(data: $0) }
            notify()
        }
    }
    /// Diameter (in points) the custom image is drawn at on screen.
    var imageSize: Double {
        didSet { defaults.set(imageSize, forKey: Keys.imageSize); notify() }
    }

    private var cachedCustomImage: NSImage?
    var customImage: NSImage? { cachedCustomImage }

    private init() {
        isVisible = defaults.object(forKey: Keys.isVisible) as? Bool ?? true
        style = CrosshairStyle(rawValue: defaults.integer(forKey: Keys.style)) ?? .cross

        if let data = defaults.data(forKey: Keys.colorData),
           let savedColor = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSColor.self], from: data) as? NSColor {
            color = savedColor
        } else {
            color = NSColor.systemGreen
        }

        length = defaults.object(forKey: Keys.length) as? Double ?? 12
        thickness = defaults.object(forKey: Keys.thickness) as? Double ?? 2
        gap = defaults.object(forKey: Keys.gap) as? Double ?? 4
        opacity = defaults.object(forKey: Keys.opacity) as? Double ?? 0.9
        showOutline = defaults.object(forKey: Keys.outline) as? Bool ?? true
        imageSize = defaults.object(forKey: Keys.imageSize) as? Double ?? 64

        if let data = defaults.data(forKey: Keys.customImageData) {
            customImageData = data
            cachedCustomImage = NSImage(data: data)
        } else {
            customImageData = nil
        }
    }

    private func notify() {
        NotificationCenter.default.post(name: .crosshairSettingsChanged, object: nil)
    }
}
