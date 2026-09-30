import Foundation

/// Forward-looking contract for AI-powered text transformations (V3 Roadmap).
///
/// Designed to support local LLMs or external providers without coupling the MVP
/// to network dependencies or third-party AI SDKs.
public protocol IntelligentTransform: Sendable {
    func transform(
        input: String,
        instruction: String
    ) async throws -> String
}
