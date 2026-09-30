import AppKit
import SwiftUI

/// Main application delegate handling lifecycle, hotkeys, status bar, and settings.
@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    public private(set) var editorController: EditorPanelController?
    public private(set) var hotKeyManager: HotKeyManager?
    private var statusBarController: StatusBarController?
    private var settingsWindow: NSWindow?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as an accessory application (menu bar item + floating HUD, no dock icon)
        NSApp.setActivationPolicy(.accessory)

        // Initialize editor controller
        let editor = EditorPanelController()
        self.editorController = editor

        // Initialize and register global ⌘⇧C shortcut
        let hotKey = HotKeyManager()
        self.hotKeyManager = hotKey

        let registered = hotKey.registerDefault { [weak self] in
            self?.editorController?.toggleOrPresent()
        }

        if !registered {
            NSLog("Warning: ClipEdit could not register global shortcut ⌘⇧C")
        }

        // Initialize status bar item
        self.statusBarController = StatusBarController(
            onTriggerEdit: { [weak self] in
                self?.editorController?.toggleOrPresent()
            },
            onOpenSettings: { [weak self] in
                self?.openSettings()
            }
        )
    }

    public func applicationWillTerminate(_ notification: Notification) {
        hotKeyManager?.unregister()
    }

    /// Opens or brings to front the settings window.
    public func openSettings() {
        if let window = settingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
        let hostingView = NSHostingView(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 340),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "ClipEdit Settings"
        window.contentView = hostingView
        window.isReleasedWhenClosed = false

        self.settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
