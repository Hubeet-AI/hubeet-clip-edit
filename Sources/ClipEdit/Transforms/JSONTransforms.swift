import Foundation

/// Formats valid JSON with clear indentation and sorted keys.
public struct PrettyJSONTransform: ClipboardTransform {
    public let id = "pretty_json"
    public let name = "Pretty JSON"
    public let shortcut: String? = nil

    public init() {}

    public func transform(_ input: String) throws -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw TransformError.emptyInput
        }

        guard let data = trimmed.data(using: .utf8) else {
            throw TransformError.invalidJSON("Unable to read input as UTF-8")
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let formattedData = try JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            )
            guard let formattedString = String(data: formattedData, encoding: .utf8) else {
                throw TransformError.invalidJSON("Unable to convert formatted data to string")
            }
            return formattedString
        } catch {
            throw TransformError.invalidJSON(error.localizedDescription)
        }
    }
}

/// Minifies valid JSON by stripping unnecessary whitespace.
public struct MinifyJSONTransform: ClipboardTransform {
    public let id = "minify_json"
    public let name = "Minify JSON"
    public let shortcut: String? = nil

    public init() {}

    public func transform(_ input: String) throws -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw TransformError.emptyInput
        }

        guard let data = trimmed.data(using: .utf8) else {
            throw TransformError.invalidJSON("Unable to read input as UTF-8")
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let minifiedData = try JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.withoutEscapingSlashes]
            )
            guard let minifiedString = String(data: minifiedData, encoding: .utf8) else {
                throw TransformError.invalidJSON("Unable to convert minified data to string")
            }
            return minifiedString
        } catch {
            throw TransformError.invalidJSON(error.localizedDescription)
        }
    }
}
