import AppKit
import XCTest
@testable import ClipEdit

final class ClipboardServiceTests: XCTestCase {
    private var testPasteboard: NSPasteboard!
    private var service: NSPasteboardService!

    override func setUp() {
        super.setUp()
        // Use an isolated pasteboard unique to this test run so user clipboard is untouched
        let uniqueName = NSPasteboard.Name("com.clipedit.tests.\(UUID().uuidString)")
        testPasteboard = NSPasteboard(name: uniqueName)
        service = NSPasteboardService(pasteboard: testPasteboard)
    }

    override func tearDown() {
        testPasteboard.clearContents()
        testPasteboard = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Reading and Writing Text

    func testWriteAndReadText() {
        let sample = "Hello, ClipEdit! 🚀"
        let writeSuccess = service.write(sample)
        XCTAssertTrue(writeSuccess)

        let content = service.read()
        switch content {
        case .text(let readString, let snapshot):
            XCTAssertEqual(readString, sample)
            XCTAssertEqual(snapshot.originalText, sample)
            XCTAssertTrue(snapshot.types.contains(NSPasteboard.PasteboardType.string.rawValue))
        default:
            XCTFail("Expected .text content, got \(content)")
        }
    }

    func testReadEmptyPasteboard() {
        testPasteboard.clearContents()
        let content = service.read()
        XCTAssertEqual(content, .empty)
    }

    func testUnicodeAndMultibyteText() {
        let unicodeText = "日本語テキスト · العربية · ¡Olé! · 👨‍👩‍👧‍👦"
        service.write(unicodeText)

        let content = service.read()
        if case .text(let text, _) = content {
            XCTAssertEqual(text, unicodeText)
        } else {
            XCTFail("Expected .text with unicode content")
        }
    }

    func testVeryLongTextReadAndWrite() {
        let largeChunk = String(repeating: "The quick brown fox jumps over the lazy dog. 🦊\n", count: 2_000) // ~100k chars
        service.write(largeChunk)

        let content = service.read()
        if case .text(let text, let snapshot) = content {
            XCTAssertEqual(text.count, largeChunk.count)
            XCTAssertEqual(snapshot.originalText?.count, largeChunk.count)
        } else {
            XCTFail("Expected .text for large payload")
        }
    }

    func testUnsupportedNonTextContent() {
        testPasteboard.clearContents()

        // Write TIFF or custom binary data without any string representation
        let dummyData = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) // PNG header
        testPasteboard.declareTypes([.png], owner: nil)
        testPasteboard.setData(dummyData, forType: .png)

        let content = service.read()
        switch content {
        case .unsupported(let types):
            XCTAssertTrue(types.contains(NSPasteboard.PasteboardType.png.rawValue))
        default:
            XCTFail("Expected .unsupported for binary/image types, got \(content)")
        }
    }

    func testSnapshotPreservation() {
        let initialText = "Original content before edit"
        service.write(initialText)

        let readContent = service.read()
        guard case .text(let text, let snapshot) = readContent else {
            XCTFail("Failed to read initial content")
            return
        }

        XCTAssertEqual(text, initialText)
        XCTAssertEqual(snapshot.originalText, initialText)

        // Simulating a cancel: we do NOT call service.write()
        // Content on pasteboard must remain identical
        let afterCancelContent = service.read()
        if case .text(let currentText, _) = afterCancelContent {
            XCTAssertEqual(currentText, initialText)
        } else {
            XCTFail("Content was unexpectedly altered")
        }
    }
}
