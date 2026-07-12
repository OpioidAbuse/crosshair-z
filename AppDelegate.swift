import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var toggleMenuItem: NSMenuItem?
    private let overlayController = CrosshairOverlayController()
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        if CrosshairSettings.shared.isVisible {
            overlayController.showCrosshairs()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Closing the settings window should NOT quit the app —
        // the crosshair keeps running from the menu bar until "Quit" is chosen.
        false
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = StatusIconFactory.makeIcon()

        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "Show Crosshair", action: #selector(toggleCrosshair(_:)), keyEquivalent: "")
        toggleItem.target = self
        toggleItem.state = CrosshairSettings.shared.isVisible ? .on : .off
        menu.addItem(toggleItem)
        toggleMenuItem = toggleItem

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Crosshair Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Crosshair", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func toggleCrosshair(_ sender: NSMenuItem) {
        CrosshairSettings.shared.isVisible.toggle()
        syncAfterVisibilityChange()
    }

    /// Called by the settings window too, so the menu checkbox and the overlay
    /// stay in sync no matter which UI toggled visibility.
    func syncAfterVisibilityChange() {
        toggleMenuItem?.state = CrosshairSettings.shared.isVisible ? .on : .off
        if CrosshairSettings.shared.isVisible {
            overlayController.showCrosshairs()
        } else {
            overlayController.hideCrosshairs()
        }
    }

    @objc private func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
