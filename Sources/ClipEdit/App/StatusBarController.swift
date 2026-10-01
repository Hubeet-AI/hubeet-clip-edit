import AppKit

/// Manages the status bar (menu bar) item for quick access, settings, and quitting.
@MainActor
public final class StatusBarController {
    private var statusItem: NSStatusItem?
    private let onTriggerEdit: () -> Void
    private let onOpenSettings: () -> Void

    public init(
        onTriggerEdit: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.onTriggerEdit = onTriggerEdit
        self.onOpenSettings = onOpenSettings
        setupStatusBar()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            if let iconPath = Bundle.main.path(forResource: "hubeet-clip-ico", ofType: "png"),
               let image = NSImage(contentsOfFile: iconPath) {
                image.size = NSSize(width: 18, height: 18)
                image.isTemplate = false
                button.image = image
            } else if let appIcon = NSImage(named: "AppIcon") {
                let iconCopy = appIcon.copy() as! NSImage
                iconCopy.size = NSSize(width: 18, height: 18)
                button.image = iconCopy
            } else {
                button.image = NSImage(
                    systemSymbolName: "doc.on.clipboard",
                    accessibilityDescription: "Hubeet ClipEdit"
                )
            }
        }

        let menu = NSMenu()

        let editItem = NSMenuItem(
            title: "Edit Clipboard",
            action: #selector(handleTriggerEdit),
            keyEquivalent: "C"
        )
        editItem.keyEquivalentModifierMask = [.command, .shift]
        editItem.target = self
        menu.addItem(editItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(handleOpenSettings),
            keyEquivalent: ","
        )
        settingsItem.keyEquivalentModifierMask = [.command]
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit ClipEdit",
            action: #selector(handleQuit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func handleTriggerEdit() {
        onTriggerEdit()
    }

    @objc private func handleOpenSettings() {
        onOpenSettings()
    }

    @objc private func handleQuit() {
        NSApplication.shared.terminate(nil)
    }
}
