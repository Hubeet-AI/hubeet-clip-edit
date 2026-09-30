import XCTest
@testable import ClipEdit

final class TransformsTests: XCTestCase {

    // MARK: - TrimTransform Tests

    func testTrimTransformStandard() throws {
        let transform = TrimTransform()
        let input = "   Hello World!   \n\n\t"
        let output = try transform.transform(input)
        XCTAssertEqual(output, "Hello World!")
    }

    func testTrimTransformEmptyString() throws {
        let transform = TrimTransform()
        let output = try transform.transform("   \n\t   ")
        XCTAssertEqual(output, "")
    }

    func testTrimTransformUnicodeAndEmoji() throws {
        let transform = TrimTransform()
        let input = "   🎉 ¡Hola, señor Pingüino! 🚀   \n"
        let output = try transform.transform(input)
        XCTAssertEqual(output, "🎉 ¡Hola, señor Pingüino! 🚀")
    }

    // MARK: - Case Transforms Tests

    func testUppercaseTransform() throws {
        let transform = UppercaseTransform()
        let input = "hello world, mañanas & café 🚀"
        let output = try transform.transform(input)
        XCTAssertEqual(output, "HELLO WORLD, MAÑANAS & CAFÉ 🚀")
    }

    func testLowercaseTransform() throws {
        let transform = LowercaseTransform()
        let input = "HELLO WORLD, MAÑANAS & CAFÉ 🚀"
        let output = try transform.transform(input)
        XCTAssertEqual(output, "hello world, mañanas & café 🚀")
    }

    // MARK: - SingleLineTransform Tests

    func testSingleLineTransformMultilinesAndTabs() throws {
        let transform = SingleLineTransform()
        let input = """
        hola
        esto es
        una prueba
        """
        let output = try transform.transform(input)
        XCTAssertEqual(output, "hola esto es una prueba")
    }

    func testSingleLineTransformCRLFAndMultipleSpaces() throws {
        let transform = SingleLineTransform()
        let input = "Line 1\r\n   Line 2\r\n\tLine 3   with   many    spaces\r\n"
        let output = try transform.transform(input)
        XCTAssertEqual(output, "Line 1 Line 2 Line 3 with many spaces")
    }

    func testSingleLineTransformEmpty() throws {
        let transform = SingleLineTransform()
        let output = try transform.transform("   \r\n  \t   \n  ")
        XCTAssertEqual(output, "")
    }

    // MARK: - JSON Transforms Tests

    func testPrettyJSONTransformValidObject() throws {
        let transform = PrettyJSONTransform()
        let input = "{\"name\":\"Gus\",\"active\":true}"
        let output = try transform.transform(input)

        // Verify it contains expected indented formatting
        XCTAssertTrue(output.contains("{\n"))
        XCTAssertTrue(output.contains("\"active\" : true") || output.contains("\"active\": true"))
        XCTAssertTrue(output.contains("\"name\" : \"Gus\"") || output.contains("\"name\": \"Gus\""))
        XCTAssertTrue(output.hasSuffix("}"))
    }

    func testPrettyJSONTransformValidArray() throws {
        let transform = PrettyJSONTransform()
        let input = "[1, 2, 3, {\"key\": \"value\"}]"
        let output = try transform.transform(input)

        XCTAssertTrue(output.hasPrefix("[\n"))
        XCTAssertTrue(output.hasSuffix("]"))
    }

    func testPrettyJSONTransformNested() throws {
        let transform = PrettyJSONTransform()
        let input = "{\"user\":{\"id\":101,\"profile\":{\"theme\":\"dark\",\"tags\":[\"swift\",\"macos\"]}}}"
        let output = try transform.transform(input)

        XCTAssertTrue(output.contains("\"tags\" : [") || output.contains("\"tags\": ["))
        XCTAssertTrue(output.contains("\"theme\" : \"dark\"") || output.contains("\"theme\": \"dark\""))
    }

    func testPrettyJSONTransformInvalidJSONThrows() {
        let transform = PrettyJSONTransform()
        let input = "not a valid json { broken"

        XCTAssertThrowsError(try transform.transform(input)) { error in
            guard let transformError = error as? TransformError else {
                XCTFail("Expected TransformError, got \(error)")
                return
            }
            if case .invalidJSON(let detail) = transformError {
                XCTAssertFalse(detail.isEmpty)
            } else {
                XCTFail("Expected .invalidJSON, got \(transformError)")
            }
        }
    }

    func testPrettyJSONTransformEmptyThrows() {
        let transform = PrettyJSONTransform()
        XCTAssertThrowsError(try transform.transform("   \n  ")) { error in
            XCTAssertEqual(error as? TransformError, .emptyInput)
        }
    }

    func testMinifyJSONTransformValid() throws {
        let transform = MinifyJSONTransform()
        let input = """
        {
          "name": "ClipEdit",
          "features": [
            "fast",
            "native"
          ]
        }
        """
        let output = try transform.transform(input)
        XCTAssertFalse(output.contains("\n"))
        XCTAssertTrue(output.contains("\"name\":\"ClipEdit\"") || output.contains("\"name\": \"ClipEdit\""))
    }

    func testMinifyJSONTransformInvalidThrows() {
        let transform = MinifyJSONTransform()
        let input = "{ key: value missing quotes }"
        XCTAssertThrowsError(try transform.transform(input))
    }

    // MARK: - TransformPipeline Tests

    func testPipelineChaining() throws {
        let pipeline = TransformPipeline(transforms: [
            TrimTransform(),
            SingleLineTransform(),
            UppercaseTransform()
        ])

        let input = """
           hello
           world
           from   clipedit
        """
        let output = try pipeline.execute(on: input)
        XCTAssertEqual(output, "HELLO WORLD FROM CLIPEDIT")
    }

    // MARK: - Very Long Text Performance

    func testVeryLongTextPerformance() throws {
        let transform = SingleLineTransform()
        let line = "Word with space and punctuation, "
        let longInput = String(repeating: line, count: 10_000) // ~330,000 characters

        measure {
            _ = try? transform.transform(longInput)
        }
    }
}
