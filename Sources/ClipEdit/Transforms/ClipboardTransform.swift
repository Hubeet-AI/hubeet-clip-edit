import Foundation

/// Errors that can occur during a clipboard text transformation.
public enum TransformError: LocalizedError, Equatable, Sendable {
    case invalidJSON(String)
    case emptyInput
    case custom(String)

    public var errorDescription: String? {
        switch self {
        case .invalidJSON(let details):
            return "Invalid JSON: \(details)"
        case .emptyInput:
            return "Content is empty"
        case .custom(let message):
            return message
        }
    }
}

/// A protocol representing a text transformation that can be applied to clipboard content.
public protocol ClipboardTransform: Sendable {
    var id: String { get }
    var name: String { get }
    var shortcut: String? { get }

    func transform(_ input: String) throws -> String
}
