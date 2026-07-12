import Cocoa

/// Draws the crosshair centered in whatever frame it's given.
/// Used both by the fullscreen overlay windows and the settings preview box.
class CrosshairView: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(settingsChanged),
                                                name: .crosshairSettingsChanged, object: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(settingsChanged),
                                                name: .crosshairSettingsChanged, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func settingsChanged() {
        needsDisplay = true
    }

    override var isOpaque: Bool { false }
    override var isFlipped: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let s = CrosshairSettings.shared
        guard s.isVisible else { return }

        let center = NSPoint(x: bounds.midX, y: bounds.midY)
        let color = s.color.withAlphaComponent(CGFloat(s.opacity))
        let length = CGFloat(s.length)
        let thickness = CGFloat(s.thickness)
        let gap = CGFloat(s.gap)

        func drawLine(from a: NSPoint, to b: NSPoint) {
            let path = NSBezierPath()
            path.lineCapStyle = .round
            path.move(to: a)
            path.line(to: b)
            if s.showOutline {
                NSColor.black.withAlphaComponent(CGFloat(s.opacity) * 0.6).setStroke()
                path.lineWidth = thickness + 2
                path.stroke()
            }
            color.setStroke()
            path.lineWidth = thickness
            path.stroke()
        }

        func drawDot() {
            let r = thickness * 1.6
            let rect = NSRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
            if s.showOutline {
                NSColor.black.withAlphaComponent(CGFloat(s.opacity) * 0.6).setFill()
                NSBezierPath(ovalIn: rect.insetBy(dx: -1, dy: -1)).fill()
            }
            color.setFill()
            NSBezierPath(ovalIn: rect).fill()
        }

        func drawCircle() {
            let rect = NSRect(x: center.x - length, y: center.y - length, width: length * 2, height: length * 2)
            let path = NSBezierPath(ovalIn: rect)
            if s.showOutline {
                NSColor.black.withAlphaComponent(CGFloat(s.opacity) * 0.6).setStroke()
                path.lineWidth = thickness + 2
                path.stroke()
            }
            color.setStroke()
            path.lineWidth = thickness
            path.stroke()
        }

        func drawCustomImage() {
            guard let image = s.customImage else { return }
            let size = CGFloat(s.imageSize)
            let rect = NSRect(x: center.x - size / 2, y: center.y - size / 2, width: size, height: size)
            image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: CGFloat(s.opacity))
        }

        switch s.style {
        case .cross, .crossDot:
            drawLine(from: NSPoint(x: center.x - length, y: center.y), to: NSPoint(x: center.x - gap, y: center.y))
            drawLine(from: NSPoint(x: center.x + gap, y: center.y), to: NSPoint(x: center.x + length, y: center.y))
            drawLine(from: NSPoint(x: center.x, y: center.y - length), to: NSPoint(x: center.x, y: center.y - gap))
            drawLine(from: NSPoint(x: center.x, y: center.y + gap), to: NSPoint(x: center.x, y: center.y + length))
            if s.style == .crossDot { drawDot() }
        case .dot:
            drawDot()
        case .circle:
            drawCircle()
        case .customImage:
            if s.customImage != nil {
                drawCustomImage()
            } else {
                // No image chosen yet — fall back to a plain cross so the
                // overlay isn't just invisible while you're picking one.
                drawLine(from: NSPoint(x: center.x - length, y: center.y), to: NSPoint(x: center.x - gap, y: center.y))
                drawLine(from: NSPoint(x: center.x + gap, y: center.y), to: NSPoint(x: center.x + length, y: center.y))
                drawLine(from: NSPoint(x: center.x, y: center.y - length), to: NSPoint(x: center.x, y: center.y - gap))
                drawLine(from: NSPoint(x: center.x, y: center.y + gap), to: NSPoint(x: center.x, y: center.y + length))
            }
        }
    }
}
