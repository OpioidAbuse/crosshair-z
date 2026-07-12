import Cocoa

/// Creates/destroys the per-screen overlay windows and keeps them in sync
/// with monitors being connected/disconnected/rearranged.
class CrosshairOverlayController {
    private var windows: [CrosshairWindow] = []

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(screensChanged),
                                                name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func showCrosshairs() {
        removeAllWindows()
        for screen in NSScreen.screens {
            let window = CrosshairWindow(screen: screen)
            window.orderFrontRegardless()
            windows.append(window)
        }
    }

    func hideCrosshairs() {
        removeAllWindows()
    }

    private func removeAllWindows() {
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
    }

    @objc private func screensChanged() {
        if CrosshairSettings.shared.isVisible {
            showCrosshairs()
        }
    }
}
