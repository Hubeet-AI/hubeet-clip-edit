import Foundation

/// Removes leading and trailing whitespace and newline characters.
public struct TrimTransform: ClipboardTransform {
    public let id = "trim"
    public let name = "Trim"
    public let shortcut: String? = nil

    public init() {}

    public func transform(_ input: String) throws -> String {
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
