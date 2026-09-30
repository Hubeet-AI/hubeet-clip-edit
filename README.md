# Hubeet ClipEdit ✂️📋

> **Clipboard Transformer & Ephemeral Editor between Copy and Paste** for macOS.

Hubeet ClipEdit introduces a lightweight, zero-latency intermediate layer between **Copy (⌘C)** and **Paste (⌘V)**. 

Instead of opening a scratch text editor, pasting, cleaning up text, re-copying, and switching back to your target app, Hubeet ClipEdit summons a floating, keyboard-first HUD directly over your current workspace. Edit in place with instant transforms, press `⌘Enter`, and paste immediately.

```text
Standard macOS Flow:
Select  →  ⌘C  →  [Switch App → Paste → Edit → Select All → ⌘C → Switch Back]  →  ⌘V

Hubeet ClipEdit Flow:
Select  →  ⌘C  →  ⌘⇧C  →  Edit / Quick Transform  →  ⌘Enter  →  ⌘V
```

---

## 💡 About Hubeet Clip Edit

**Hubeet Clip Edit** is a lightweight macOS clipboard editor and transformer built as part of the **[Hubeet](https://www.hubeet.com/)** ecosystem.

It introduces a simple intermediate layer between Copy and Paste:

$$\text{Copy} \longrightarrow \text{Edit / Transform} \longrightarrow \text{Paste}$$

The goal is to make clipboard content directly manipulable without interrupting the user's workflow or requiring a separate text editor.

Hubeet Clip Edit is designed around a simple principle:
> **The clipboard should not only store information. It should be a place where information can be transformed before it moves somewhere else.**

### Hubeet

[Hubeet](https://www.hubeet.com/) is an AI platform that connects people, enterprise systems, data sources, APIs, documents, and AI agents through natural language interfaces.

Hubeet Clip Edit explores that same idea at the operating-system level: creating a lightweight interaction layer between the user and the information moving across applications.

Future versions may integrate Hubeet capabilities to provide intelligent clipboard transformations such as:
- Rewriting content
- Summarization
- Translation
- Structured data extraction
- Sensitive-data redaction
- Format conversion
- Contextual transformations
- Custom enterprise actions
- AI-powered transformation pipelines

**Example workflow:**
```text
⌘C  →  Hubeet Clip Edit  →  Edit / Transform / Ask AI  →  ⌘V
```

This allows the clipboard to evolve from a passive buffer into an active information transformation layer.

### Philosophy

Hubeet Clip Edit should feel less like opening another application and more like invoking a native operating-system capability.

The fundamental interaction must remain:
```text
Invoke  →  Edit  →  Confirm  →  Paste
```
Every new feature should preserve that simplicity.

### Project Details

- **Project:** Hubeet Clip Edit
- **Platform:** macOS (macOS 14+)
- **Technology:** Swift / SwiftUI / AppKit
- **Website:** [https://www.hubeet.com](https://www.hubeet.com/)
- **Product Ecosystem:** Part of the Hubeet ecosystem. Learn more at [https://www.hubeet.com](https://www.hubeet.com/).

---

## ✨ Features

- ⚡️ **Global Shortcut (`⌘ + ⇧ + C`)**: Intercepts anywhere across macOS without stealing ongoing application state.
- 🪟 **Spotlight-Style HUD Panel**: Floating, borderless, translucent macOS design (`NSPanel`) that appears instantly over your active screen.
- ⌨️ **Keyboard-First Workflow**:
  - `⌘ + ⇧ + C`: Summon editor with current clipboard content.
  - `Esc`: Cancel instantly without touching your clipboard and restore focus to your previous app.
  - `⌘ + Enter`: Commit changes to clipboard, dismiss panel, and restore focus to your previous app.
- 🛠 **Built-in Quick Transforms**:
  - **Trim**: Strip leading & trailing whitespace and line breaks.
  - **Single Line**: Collapse multiple lines and messy whitespace into a clean single line.
  - **UPPERCASE**: Convert text to uppercase.
  - **lowercase**: Convert text to lowercase.
  - **Pretty JSON**: Format & indent JSON with sorted keys. Invalid JSON displays discrete non-destructive feedback without corrupting your text.
  - **Minify JSON**: Strip whitespace from JSON data.
- 📊 **Realtime Indicators**: Live character and line counter (`438 chars · 12 lines`).
- 🛡 **100% Local & Privacy-Conscious**:
  - Zero network calls.
  - Zero telemetry or analytics.
  - Zero logging of clipboard content.
  - In-memory ephemeral storage only — nothing written to disk, SQLite, or UserDefaults.
- 🚀 **Zero Accessibility Permissions Required**: Built on native Carbon Event HotKeys, eliminating the need to prompt users for Accessibility or Input Monitoring permissions in macOS Settings.
- ⚙️ **Menu Bar & Settings**: Minimal menu bar item with Launch at Login support (`SMAppService`) and preference overview.

---

## 🏗 Architecture

ClipEdit is built purely in Swift for native macOS performance, following a clean, modular structure:

```text
ClipEdit/
├── App/
│   ├── ClipEditApp.swift          # SwiftUI App lifecycle & Settings scene
│   ├── AppDelegate.swift          # Global coordinator & activation policy
│   └── StatusBarController.swift  # Menu bar status item & actions
├── Clipboard/
│   ├── ClipboardContent.swift     # Content model (.text, .unsupported, .empty)
│   ├── ClipboardSnapshot.swift    # Snapshot model preserving pre-edit state
│   └── ClipboardService.swift     # NSPasteboard service abstraction
├── HotKey/
│   ├── CarbonHotKey.swift         # Carbon RegisterEventHotKey wrapper
│   └── HotKeyManager.swift        # Global hotkey registration & state
├── Editor/
│   ├── EditorPanel.swift          # Floating NSPanel subclass
│   ├── EditorPanelController.swift# Window presentation, lifecycle & focus handoff
│   ├── EditorViewModel.swift      # Observable state machine, transforms & indicators
│   ├── EditorView.swift           # HUD UI with macOS vibrancy & buttons
│   └── NativeTextView.swift       # NSTextView NSViewRepresentable with hotkeys
├── Transforms/
│   ├── ClipboardTransform.swift   # Protocol for text transformations & error types
│   ├── TrimTransform.swift        # Leading/trailing whitespace trimmer
│   ├── CaseTransforms.swift       # Uppercase and Lowercase transforms
│   ├── SingleLineTransform.swift  # Multi-line & whitespace collapser
│   ├── JSONTransforms.swift       # Pretty Print and Minify JSON transforms
│   ├── TransformPipeline.swift    # Sequential transformation chainer
│   └── IntelligentTransform.swift # Protocol stub prepared for future AI (V3)
├── Settings/
│   ├── SettingsView.swift         # Preferences, shortcuts & privacy details
│   └── LaunchAtLoginManager.swift # SMAppService integration
└── Resources/
    ├── Info.plist                 # LSUIElement agent configuration
    └── ClipEdit.entitlements      # macOS entitlements
```

---

## 💻 Requirements

- **macOS**: macOS 14.0 (Sonoma) or newer (macOS 15 / 26 Sequoia+ compatible).
- **Xcode**: Xcode 15.0+ / Xcode 16+.
- **Swift**: Swift 5.9 / Swift 6.0+.

---

## 🛠 Compilation & Build

### Option 1: Xcode
You can open `ClipEdit.xcodeproj` directly in Xcode:
```bash
open ClipEdit.xcodeproj
```
Select the `ClipEdit` scheme and press `⌘ + R` to build and run, or `⌘ + U` to execute unit tests.

### Option 2: Command Line (`xcodebuild`)
To build the application bundle:
```bash
xcodebuild -project ClipEdit.xcodeproj -scheme ClipEdit build
```

To run the test suite:
```bash
xcodebuild -project ClipEdit.xcodeproj -scheme ClipEditTests test
```

### Project Generation with XcodeGen (Optional)
The project definition is maintained in `project.yml`. If you modify targets or source layouts, regenerate the Xcode project at any time:
```bash
xcodegen generate
```

---

## 🚀 How to Run & Verification Workflow

1. Launch `ClipEdit.app` (or run it via Xcode / derived data).
2. The ClipEdit icon appears in the macOS menu bar.
3. Open any application (e.g. Safari, TextEdit, Terminal, VS Code, Notes).
4. Copy text to the clipboard (`⌘C`):
   ```text
   Hello wrld
   ```
5. Press the global shortcut:
   ```text
   ⌘ + ⇧ + C
   ```
6. The ClipEdit HUD appears instantly centered on screen, focused and ready to type.
7. Edit the text to:
   ```text
   Hello world
   ```
8. Press:
   ```text
   ⌘ + Enter
   ```
9. The HUD closes, the edited text is committed to your clipboard, and focus returns to your previous application.
10. Press `⌘V` in your application to paste the modified text.

---

## 🔒 Permissions & Privacy

### Do I need to grant Accessibility or Input Monitoring permissions?
**No.** ClipEdit registers its global hotkey using the native Carbon `RegisterEventHotKey` API, and accesses clipboard data through official `NSPasteboard` APIs. It does not monitor keyboard events outside its own focused window, nor does it inject synthetic keystrokes. As a result, macOS does not require Accessibility, Screen Recording, or Input Monitoring privileges.

### Clipboard Privacy
- ClipEdit operates 100% locally.
- It does not save clipboard history to disk, caches, or logs.
- Memory allocated for text editing is released when the panel dismisses.

---

## ⚠️ Known Behaviors & Edge Cases

- **Non-Text Clipboard Content**: If the clipboard contains an image, PDF, or file list, ClipEdit displays: *"Clipboard content is not editable as text"* without destroying or modifying the underlying clipboard items.
- **Focus Restoration**: ClipEdit tracks `NSWorkspace.shared.frontmostApplication` before making its panel key. When committing (`⌘Enter`) or cancelling (`Esc`), it reactivates the previous application. Certain sandboxed full-screen apps or games with exclusive focus may require a manual click to regain cursor input.
- **Focus Loss**: In accordance with user safety guidelines, ClipEdit does *not* auto-dismiss when clicking away, preventing accidental loss of pending edits. Dismissal requires explicit `Esc`, `⌘Enter`, or the close button.

---

## 🗺 Roadmap

### V1 (Current MVP)
- [x] Ephemeral clipboard text editing with instant global shortcut (`⌘⇧C`).
- [x] Keyboard-first HUD (`NSPanel`) with autofocus and Esc/⌘Enter handlers.
- [x] Core transforms: Trim, Plain Text, UPPERCASE, lowercase, Single Line, Pretty JSON, Minify JSON.
- [x] Real-time character & line indicators.
- [x] Isolated test suite for transforms and clipboard operations.
- [x] Launch at Login with `SMAppService`.

### V2
- [ ] Configurable hotkeys from Settings UI.
- [ ] Optional opt-in local clipboard history ring.
- [ ] Rich Text (RTF) and HTML source mode toggling.
- [ ] Regex find & replace drawer.
- [ ] Custom user-scripted transforms (JavaScript / Shell).

### V3
- [ ] **`⌘K` Intelligent Transform Palette**:
  - Contextual AI prompts: "Summarize", "Translate to English", "Redact sensitive keys", "Format as markdown table".
  - Support for local on-device models via Apple Silicon / MLX, and optional custom API keys (OpenAI / Gemini / Claude).

### V4
- [ ] Image OCR to editable text.
- [ ] File list path transformations.
- [ ] Developer extension plugins.
