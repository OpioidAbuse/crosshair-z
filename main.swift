import Cocoa

// Traditional manual entry point — works all the way back to very old
// macOS versions and doesn't require a Main.storyboard/xib.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // menu bar app, no Dock icon, no app switcher entry
app.run()
