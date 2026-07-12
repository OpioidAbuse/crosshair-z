import Cocoa

enum StatusIconFactory {
    static func makeIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()

        let path = NSBezierPath()
        path.lineWidth = 1.4
        path.lineCapStyle = .round
        NSColor.black.setStroke()

        let c = NSPoint(x: size.width / 2, y: size.height / 2)
        path.move(to: NSPoint(x: c.x - 7, y: c.y)); path.line(to: NSPoint(x: c.x - 2, y: c.y))
        path.move(to: NSPoint(x: c.x + 2, y: c.y)); path.line(to: NSPoint(x: c.x + 7, y: c.y))
        path.move(to: NSPoint(x: c.x, y: c.y - 7)); path.line(to: NSPoint(x: c.x, y: c.y - 2))
        path.move(to: NSPoint(x: c.x, y: c.y + 2)); path.line(to: NSPoint(x: c.x, y: c.y + 7))
        path.stroke()

        image.unlockFocus()
        image.isTemplate = true // adapts to light/dark menu bar automatically
        return image
    }
}
