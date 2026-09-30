import Foundation

/// Converts text to uppercase.
public struct UppercaseTransform: ClipboardTransform {
    public let id = "uppercase"
    public let name = "UPPERCASE"
    public let shortcut: String? = nil

    public init() {}

    public func transform(_ input: String) throws -> String {
        return input.uppercased()
    }
}

/// Converts text to lowercase.
public struct LowercaseTransform: ClipboardTransform {
    public let id = "lowercase"
    public let name = "lowercase"
    public let shortcut: String? = nil

    public init() {}

    public func transform(_ input: String) throws -> String {
        return input.lowercased()
    }
}
