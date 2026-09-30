import Foundation

/// Chains multiple `ClipboardTransform` instances sequentially.
public struct TransformPipeline: Sendable {
    public let transforms: [ClipboardTransform]

    public init(transforms: [ClipboardTransform]) {
        self.transforms = transforms
    }

    /// Executes all transforms in sequence.
    public func execute(on input: String) throws -> String {
        var current = input
        for transform in transforms {
            current = try transform.transform(current)
        }
        return current
    }
}
