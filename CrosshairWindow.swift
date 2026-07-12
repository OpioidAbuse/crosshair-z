import Cocoa

/// One of these gets created per connected display. It's borderless,
/// transparent, click-through, and floats above basically everything
/// (including fullscreen apps) on every Space.
class CrosshairWindow: NSWindow {

    init(screen: NSScreen) {
        super.init(contentRect: screen.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        setFrame(screen.frame, display: false)

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true          // clicks/drags pass straight through to whatever is underneath
        isReleasedWhenClosed = false
        level = .screenSaver                // sits above normal windows and fullscreen apps
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]

        let view = CrosshairView(frame: NSRect(origin: .zero, size: screen.frame.size))
        view.autoresizingMask = [.width, .height]
        contentView = view
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
