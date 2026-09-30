import AppKit

/// Floating HUD-style panel for clipboard editing.
///
/// Configured to float above all standard application windows and accept
/// keyboard focus immediately when summoned.
public final class EditorPanel: NSPanel {
    public init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .fullSizeContentView,
                .closable,
                .resizable
            ],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.isFloatingPanel = true
        self.hidesOnDeactivate = false
        self.isMovableByWindowBackground = true
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.minSize = NSSize(width: 480, height: 260)
    }

    override public var canBecomeKey: Bool {
        return true
    }

    override public var canBecomeMain: Bool {
        return true
    }

    /// Center on the screen containing the current mouse cursor or active window.
    public func centerOnCurrentScreen() {
        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first(where: { NSPointInRect(mouseLocation, $0.frame) }) ?? NSScreen.main

        guard let screen = targetScreen else {
            self.center()
            return
        }

        let screenVisibleFrame = screen.visibleFrame
        let panelFrame = self.frame
        let originX = screenVisibleFrame.midX - (panelFrame.width / 2.0)
        let originY = screenVisibleFrame.midY - (panelFrame.height / 2.0) + 40.0 // slightly above optical center

        self.setFrameOrigin(NSPoint(x: originX, y: originY))
    }
}
