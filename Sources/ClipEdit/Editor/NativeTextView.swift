import AppKit
import SwiftUI

/// Custom NSTextView subclass that handles global editor key commands.
final class EditorNSTextView: NSTextView {
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?

    override func keyDown(with event: NSEvent) {
        // Esc key (53) -> Cancel
        if event.keyCode == 53 {
            onCancel?()
            return
        }

        // Cmd + Return (Return = 36, Keypad Enter = 76) -> Confirm
        if (event.keyCode == 36 || event.keyCode == 76) && event.modifierFlags.contains(.command) {
            onConfirm?()
            return
        }

        super.keyDown(with: event)
    }

    override var acceptsFirstResponder: Bool {
        return true
    }
}

/// SwiftUI wrapper around AppKit's `NSTextView` for high-performance, native text editing.
public struct NativeTextView: NSViewRepresentable {
    @Binding public var text: String
    public var onConfirm: () -> Void
    public var onCancel: () -> Void

    public init(
        text: Binding<String>,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self._text = text
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false

        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(containerSize: NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)

        let textView = EditorNSTextView(frame: NSRect(origin: .zero, size: contentSize), textContainer: textContainer)
        textView.minSize = NSSize(width: 0, height: contentSize.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.drawsBackground = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 13.5, weight: .regular)
        textView.textColor = NSColor.textColor
        textView.insertionPointColor = NSColor.controlAccentColor
        textView.isRichText = false
        textView.allowsUndo = true
        textView.textContainerInset = NSSize(width: 8, height: 8)

        // Disable automatic modifications that corrupt code/JSON
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false

        textView.delegate = context.coordinator
        textView.onConfirm = onConfirm
        textView.onCancel = onCancel

        textView.string = text
        context.coordinator.textView = textView
        scrollView.documentView = textView

        // Schedule immediate focus once added to window hierarchy
        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
            // Select all text for quick overwrite, or place cursor at end
            textView.selectAll(nil)
        }

        return scrollView
    }

    public func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? EditorNSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
        textView.onConfirm = onConfirm
        textView.onCancel = onCancel

        // Ensure focus is kept if window is key
        if let window = textView.window, window.isKeyWindow, window.firstResponder !== textView {
            window.makeFirstResponder(textView)
        }
    }

    public final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NativeTextView
        weak var textView: EditorNSTextView?

        init(_ parent: NativeTextView) {
            self.parent = parent
        }

        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            if parent.text != textView.string {
                parent.text = textView.string
            }
        }
    }
}
