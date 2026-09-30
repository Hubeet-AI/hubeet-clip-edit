import AppKit
import Foundation

/// Protocol defining clipboard interactions for reading and writing text representations.
public protocol ClipboardServiceProtocol: Sendable {
    func read() -> ClipboardContent
    @discardableResult
    func write(_ text: String) -> Bool
    func detectAvailableTypes() -> [NSPasteboard.PasteboardType]
}

/// Native implementation backed by `NSPasteboard.general`.
public final class NSPasteboardService: ClipboardServiceProtocol, @unchecked Sendable {
    private let pasteboard: NSPasteboard

    public init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }

    /// Read the current content of the clipboard.
    public func read() -> ClipboardContent {
        let changeCount = pasteboard.changeCount
        let types = detectAvailableTypes()
        let typeStrings = types.map(\.rawValue)

        if types.isEmpty {
            return .empty
        }

        // Check for textual content in order of specificity
        let textTypes: [NSPasteboard.PasteboardType] = [
            .string,
            NSPasteboard.PasteboardType("public.utf8-plain-text"),
            NSPasteboard.PasteboardType("public.plain-text")
        ]

        for textType in textTypes {
            if let string = pasteboard.string(forType: textType) {
                let snapshot = ClipboardSnapshot(
                    changeCount: changeCount,
                    timestamp: Date(),
                    types: typeStrings,
                    originalText: string
                )
                return .text(string, snapshot: snapshot)
            }
        }

        // If there are types present but none could be decoded as plain text
        return .unsupported(types: typeStrings)
    }

    /// Overwrite the clipboard contents with new plain text.
    @discardableResult
    public func write(_ text: String) -> Bool {
        pasteboard.clearContents()
        return pasteboard.setString(text, forType: .string)
    }

    /// Detect all available types currently registered in the pasteboard.
    public func detectAvailableTypes() -> [NSPasteboard.PasteboardType] {
        return pasteboard.types ?? []
    }
}
