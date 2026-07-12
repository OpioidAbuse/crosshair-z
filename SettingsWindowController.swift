import Cocoa

class SettingsWindowController: NSWindowController {
    private var previewView: CrosshairView!
    private var sliderValueLabels: [String: NSTextField] = [:]
    private var stylePopup: NSPopUpButton?
    private var thumbnailView: NSImageView?

    convenience init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 380, height: 610),
                               styleMask: [.titled, .closable, .miniaturizable],
                               backing: .buffered, defer: false)
        window.title = "Crosshair Settings"
        window.isReleasedWhenClosed = false
        window.center()
        self.init(window: window)
        buildUI()
    }

    private func buildUI() {
        guard let window = window, let contentView = window.contentView else { return }
        let s = CrosshairSettings.shared

        // --- Live preview box -------------------------------------------------
        let previewBox = NSView(frame: NSRect(x: 20, y: 440, width: 340, height: 150))
        previewBox.wantsLayer = true
        previewBox.layer?.backgroundColor = NSColor(calibratedWhite: 0.13, alpha: 1).cgColor
        previewBox.layer?.cornerRadius = 8
        contentView.addSubview(previewBox)

        previewView = CrosshairView(frame: previewBox.bounds)
        previewView.autoresizingMask = [.width, .height]
        previewBox.addSubview(previewView)

        var y: CGFloat = 406

        // --- Visible checkbox --------------------------------------------------
        let visibleCheckbox = NSButton(checkboxWithTitle: "Crosshair Visible", target: self, action: #selector(visibleChanged(_:)))
        visibleCheckbox.frame = NSRect(x: 20, y: y, width: 250, height: 24)
        visibleCheckbox.state = s.isVisible ? .on : .off
        contentView.addSubview(visibleCheckbox)
        y -= 36

        // --- Style popup ---------------------------------------------------
        addLabel("Style", y: y, in: contentView)
        let stylePopup = NSPopUpButton(frame: NSRect(x: 140, y: y - 4, width: 220, height: 24))
        CrosshairStyle.allCases.forEach { stylePopup.addItem(withTitle: $0.displayName) }
        stylePopup.selectItem(at: s.style.rawValue)
        stylePopup.target = self
        stylePopup.action = #selector(styleChanged(_:))
        contentView.addSubview(stylePopup)
        self.stylePopup = stylePopup
        y -= 36

        // --- Color well ------------------------------------------------------
        addLabel("Color", y: y, in: contentView)
        let colorWell = NSColorWell(frame: NSRect(x: 140, y: y - 2, width: 50, height: 24))
        colorWell.color = s.color
        colorWell.target = self
        colorWell.action = #selector(colorChanged(_:))
        contentView.addSubview(colorWell)
        y -= 36

        // --- Sliders ---------------------------------------------------------
        y = addSlider(title: "Length", value: s.length, min: 4, max: 80, y: y, in: contentView, action: #selector(lengthChanged(_:)), suffix: "")
        y = addSlider(title: "Thickness", value: s.thickness, min: 1, max: 10, y: y, in: contentView, action: #selector(thicknessChanged(_:)), suffix: "")
        y = addSlider(title: "Gap", value: s.gap, min: 0, max: 30, y: y, in: contentView, action: #selector(gapChanged(_:)), suffix: "")
        y = addSlider(title: "Opacity", value: s.opacity * 100, min: 10, max: 100, y: y, in: contentView, action: #selector(opacityChanged(_:)), suffix: "%")

        // --- Outline checkbox -------------------------------------------------
        let outlineCheckbox = NSButton(checkboxWithTitle: "Show dark outline (helps on bright backgrounds)", target: self, action: #selector(outlineChanged(_:)))
        outlineCheckbox.frame = NSRect(x: 20, y: y - 4, width: 340, height: 24)
        outlineCheckbox.state = s.showOutline ? .on : .off
        contentView.addSubview(outlineCheckbox)
        y -= 40

        // --- Divider ----------------------------------------------------------
        let divider = NSBox(frame: NSRect(x: 20, y: y + 10, width: 340, height: 1))
        divider.boxType = .separator
        contentView.addSubview(divider)
        y -= 14

        // --- Custom image section ---------------------------------------------
        let customImageLabel = NSTextField(labelWithString: "Custom Image (PNG) — select \"Custom Image\" above to use it")
        customImageLabel.font = NSFont.systemFont(ofSize: 11)
        customImageLabel.textColor = .secondaryLabelColor
        customImageLabel.frame = NSRect(x: 20, y: y, width: 340, height: 16)
        contentView.addSubview(customImageLabel)
        y -= 30

        let thumbnail = NSImageView(frame: NSRect(x: 20, y: y - 40, width: 48, height: 48))
        thumbnail.imageScaling = .scaleProportionallyUpOrDown
        thumbnail.image = s.customImage
        thumbnail.wantsLayer = true
        thumbnail.layer?.borderColor = NSColor.separatorColor.cgColor
        thumbnail.layer?.borderWidth = 1
        thumbnail.layer?.cornerRadius = 6
        contentView.addSubview(thumbnail)
        self.thumbnailView = thumbnail

        let chooseButton = NSButton(title: "Choose PNG…", target: self, action: #selector(choosePNGClicked))
        chooseButton.frame = NSRect(x: 80, y: y - 12, width: 130, height: 26)
        chooseButton.bezelStyle = .rounded
        contentView.addSubview(chooseButton)

        let clearButton = NSButton(title: "Clear", target: self, action: #selector(clearImageClicked))
        clearButton.frame = NSRect(x: 218, y: y - 12, width: 80, height: 26)
        clearButton.bezelStyle = .rounded
        contentView.addSubview(clearButton)
        y -= 60

        // --- Image size slider --------------------------------------------------
        y = addSlider(title: "Image Size", value: s.imageSize, min: 16, max: 256, y: y, in: contentView, action: #selector(imageSizeChanged(_:)), suffix: "px")

        previewView.needsDisplay = true
    }

    private func addLabel(_ text: String, y: CGFloat, in view: NSView) {
        let label = NSTextField(labelWithString: text)
        label.frame = NSRect(x: 20, y: y, width: 110, height: 20)
        view.addSubview(label)
    }

    private func addSlider(title: String, value: Double, min: Double, max: Double, y: CGFloat, in view: NSView, action: Selector, suffix: String) -> CGFloat {
        addLabel(title, y: y, in: view)
        let slider = NSSlider(frame: NSRect(x: 140, y: y - 2, width: 160, height: 24))
        slider.minValue = min
        slider.maxValue = max
        slider.doubleValue = value
        slider.target = self
        slider.action = action
        view.addSubview(slider)

        let valueLabel = NSTextField(labelWithString: "\(Int(value))\(suffix)")
        valueLabel.frame = NSRect(x: 305, y: y, width: 55, height: 20)
        view.addSubview(valueLabel)
        sliderValueLabels[title] = valueLabel

        return y - 36
    }

    @objc private func visibleChanged(_ sender: NSButton) {
        CrosshairSettings.shared.isVisible = sender.state == .on
        (NSApp.delegate as? AppDelegate)?.syncAfterVisibilityChange()
    }

    @objc private func styleChanged(_ sender: NSPopUpButton) {
        CrosshairSettings.shared.style = CrosshairStyle(rawValue: sender.indexOfSelectedItem) ?? .cross
    }

    @objc private func colorChanged(_ sender: NSColorWell) {
        CrosshairSettings.shared.color = sender.color
    }

    @objc private func lengthChanged(_ sender: NSSlider) {
        CrosshairSettings.shared.length = sender.doubleValue
        sliderValueLabels["Length"]?.stringValue = "\(Int(sender.doubleValue))"
    }

    @objc private func thicknessChanged(_ sender: NSSlider) {
        CrosshairSettings.shared.thickness = sender.doubleValue
        sliderValueLabels["Thickness"]?.stringValue = "\(Int(sender.doubleValue))"
    }

    @objc private func gapChanged(_ sender: NSSlider) {
        CrosshairSettings.shared.gap = sender.doubleValue
        sliderValueLabels["Gap"]?.stringValue = "\(Int(sender.doubleValue))"
    }

    @objc private func opacityChanged(_ sender: NSSlider) {
        CrosshairSettings.shared.opacity = sender.doubleValue / 100.0
        sliderValueLabels["Opacity"]?.stringValue = "\(Int(sender.doubleValue))%"
    }

    @objc private func outlineChanged(_ sender: NSButton) {
        CrosshairSettings.shared.showOutline = sender.state == .on
    }

    @objc private func choosePNGClicked() {
        let panel = NSOpenPanel()
        panel.title = "Choose a Crosshair Image"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        // allowedFileTypes (rather than the newer UTType-based API) keeps this
        // compatible with the macOS 10.13 minimum deployment target.
        panel.allowedFileTypes = ["png"]

        guard let window = window else { return }
        panel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = panel.url,
                  let data = try? Data(contentsOf: url),
                  let image = NSImage(data: data) else { return }
            CrosshairSettings.shared.customImageData = data
            CrosshairSettings.shared.style = .customImage
            self?.thumbnailView?.image = image
            self?.refreshStylePopupSelection()
        }
    }

    @objc private func clearImageClicked() {
        CrosshairSettings.shared.customImageData = nil
        thumbnailView?.image = nil
        if CrosshairSettings.shared.style == .customImage {
            CrosshairSettings.shared.style = .cross
            refreshStylePopupSelection()
        }
    }

    @objc private func imageSizeChanged(_ sender: NSSlider) {
        CrosshairSettings.shared.imageSize = sender.doubleValue
        sliderValueLabels["Image Size"]?.stringValue = "\(Int(sender.doubleValue))px"
    }

    /// Keeps the style dropdown in sync when picking/clearing an image changes
    /// the style programmatically (rather than via the dropdown itself).
    private func refreshStylePopupSelection() {
        stylePopup?.selectItem(at: CrosshairSettings.shared.style.rawValue)
    }
}
