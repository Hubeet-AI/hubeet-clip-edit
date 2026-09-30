import Combine
import Foundation

public enum EditorState: Equatable {
    case idle
    case editing
    case unsupportedClipboard(types: [String])
    case emptyClipboard
}

@MainActor
public final class EditorViewModel: ObservableObject {
    @Published public var text: String = ""
    @Published public var state: EditorState = .idle
    @Published public var feedbackMessage: String? = nil
    @Published public var feedbackIsError: Bool = false

    public let transforms: [ClipboardTransform] = [
        TrimTransform(),
        SingleLineTransform(),
        UppercaseTransform(),
        LowercaseTransform(),
        PrettyJSONTransform(),
        MinifyJSONTransform()
    ]

    private var feedbackTask: Task<Void, Never>?
    public var onCommit: ((String) -> Void)?
    public var onCancel: (() -> Void)?

    public init() {}

    public var characterCount: Int {
        text.count
    }

    public var lineCount: Int {
        if text.isEmpty { return 0 }
        return text.split(separator: "\n", omittingEmptySubsequences: false).count
    }

    public func loadContent(_ content: ClipboardContent) {
        feedbackTask?.cancel()
        feedbackMessage = nil
        feedbackIsError = false

        switch content {
        case .text(let initialText, _):
            self.text = initialText
            self.state = .editing
        case .unsupported(let types):
            self.text = ""
            self.state = .unsupportedClipboard(types: types)
        case .empty:
            self.text = ""
            self.state = .emptyClipboard
        }
    }

    public func applyTransform(_ transform: ClipboardTransform) {
        do {
            let result = try transform.transform(text)
            self.text = result
            showFeedback("\(transform.name) applied", isError: false)
        } catch let error as TransformError {
            showFeedback(error.localizedDescription, isError: true)
        } catch {
            showFeedback(error.localizedDescription, isError: true)
        }
    }

    public func confirm() {
        guard state == .editing else {
            cancel()
            return
        }
        onCommit?(text)
    }

    public func cancel() {
        onCancel?()
    }

    public func showFeedback(_ message: String, isError: Bool) {
        feedbackTask?.cancel()
        feedbackMessage = message
        feedbackIsError = isError

        feedbackTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if !Task.isCancelled {
                self.feedbackMessage = nil
                self.feedbackIsError = false
            }
        }
    }

    public func reset() {
        feedbackTask?.cancel()
        text = ""
        feedbackMessage = nil
        feedbackIsError = false
        state = .idle
    }
}
