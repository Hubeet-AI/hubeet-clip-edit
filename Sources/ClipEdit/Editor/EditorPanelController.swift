import AppKit
import SwiftUI

/// Controller responsible for managing the floating editor panel, clipboard integration,
/// and application focus handoffs.
@MainActor
public final class EditorPanelController {
    private let panel: EditorPanel
    private let viewModel: EditorViewModel
    private let clipboardService: ClipboardServiceProtocol
    private var previousApp: NSRunningApplication?

    public init(clipboardService: ClipboardServiceProtocol = NSPasteboardService()) {
        self.clipboardService = clipboardService
        self.viewModel = EditorViewModel()

        let initialRect = NSRect(x: 0, y: 0, width: 580, height: 340)
        self.panel = EditorPanel(contentRect: initialRect)

        let rootView = EditorView(viewModel: viewModel)
        let hostingView = NSHostingView(rootView: rootView)
        self.panel.contentView = hostingView

        setupCallbacks()
    }

    private func setupCallbacks() {
        viewModel.onCommit = { [weak self] newText in
            guard let self = self else { return }
            self.commit(text: newText)
        }

        viewModel.onCancel = { [weak self] in
            guard let self = self else { return }
            self.cancel()
        }
    }

    /// Toggles or brings the floating editor panel to the front.
    public func toggleOrPresent() {
        if panel.isVisible {
            // Already visible: bring to front without resetting ongoing edits
            NSApp.activate(ignoringOtherApps: true)
            panel.makeKeyAndOrderFront(nil)
            return
        }

        present()
    }

    /// Presents the editor panel with the current clipboard content.
    public func present() {
        // Capture previous frontmost application for focus restoration
        if let currentApp = NSWorkspace.shared.frontmostApplication,
           currentApp.bundleIdentifier != Bundle.main.bundleIdentifier {
            self.previousApp = currentApp
        }

        // Read clipboard content
        let content = clipboardService.read()
        viewModel.loadContent(content)

        // Position and display panel
        panel.centerOnCurrentScreen()
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    /// Commits changes to the system clipboard and restores focus.
    private func commit(text: String) {
        clipboardService.write(text)
        closeAndRestoreFocus()
    }

    /// Cancels editing without modifying clipboard, and restores focus.
    private func cancel() {
        closeAndRestoreFocus()
    }

    /// Closes panel, frees temporary memory, and reactivates the previous application.
    private func closeAndRestoreFocus() {
        panel.orderOut(nil)
        viewModel.reset()

        if let app = previousApp, !app.isTerminated {
            app.activate(options: [.activateIgnoringOtherApps])
        }
        previousApp = nil
    }
}
