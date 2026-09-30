import Foundation

/// Collapses multi-line text into a single line, collapsing consecutive whitespace characters.
public struct SingleLineTransform: ClipboardTransform {
    public let id = "single_line"
    public let name = "Single Line"
    public let shortcut: String? = nil

    public init() {}

    public func transform(_ input: String) throws -> String {
        // Split by whitespaces and newlines, drop empty components, and rejoin with a single space
        let tokens = input.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return tokens.joined(separator: " ")
    }
}
