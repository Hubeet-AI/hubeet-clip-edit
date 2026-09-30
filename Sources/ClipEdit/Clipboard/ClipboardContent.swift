import Foundation

/// The content read from the system clipboard.
public enum ClipboardContent: Equatable, Sendable {
    /// Editable text with an associated pre-edit snapshot.
    case text(String, snapshot: ClipboardSnapshot)

    /// Clipboard contains data (e.g. image, file, PDF) that is not plain text.
    case unsupported(types: [String])

    /// Clipboard has no items or content.
    case empty
}
