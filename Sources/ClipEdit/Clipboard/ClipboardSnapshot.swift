import AppKit
import Foundation

/// Represents a logical snapshot of the clipboard state before editing starts.
public struct ClipboardSnapshot: Equatable, Sendable {
    public let changeCount: Int
    public let timestamp: Date
    public let types: [String]
    public let originalText: String?

    public init(
        changeCount: Int,
        timestamp: Date = Date(),
        types: [String],
        originalText: String?
    ) {
        self.changeCount = changeCount
        self.timestamp = timestamp
        self.types = types
        self.originalText = originalText
    }
}
