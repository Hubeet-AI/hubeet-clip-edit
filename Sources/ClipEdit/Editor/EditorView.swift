import SwiftUI

/// Main UI for the floating clipboard editor.
public struct EditorView: View {
    @ObservedObject public var viewModel: EditorViewModel

    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            headerView

            Divider()
                .opacity(0.4)

            // Content Area
            contentArea
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .opacity(0.4)

            // Footer Bar
            footerView
        }
        .frame(minWidth: 540, minHeight: 320)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 8) {
            headerIconView

            Text("Hubeet ClipEdit")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            Spacer()

            if viewModel.state == .editing {
                HStack(spacing: 4) {
                    Text("\(viewModel.characterCount) chars")
                    Text("·")
                    Text("\(viewModel.lineCount) lines")
                }
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(Color.primary.opacity(0.06))
                )
            }

            Button {
                viewModel.cancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 18, height: 18)
                    .background(Circle().fill(Color.primary.opacity(0.08)))
            }
            .buttonStyle(.plain)
            .help("Close without saving (Esc)")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var headerIconView: some View {
        if let path = Bundle.main.path(forResource: "hubeet-clip-ico", ofType: "png"),
           let nsImage = NSImage(contentsOfFile: path) {
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        } else if let icon = NSImage(named: "AppIcon") ?? NSApp.applicationIconImage {
            Image(nsImage: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        } else {
            Image(systemName: "doc.on.clipboard.fill")
                .foregroundStyle(Color.accentColor)
                .imageScale(.medium)
        }
    }

    // MARK: - Content
    @ViewBuilder
    private var contentArea: some View {
        switch viewModel.state {
        case .editing:
            NativeTextView(
                text: $viewModel.text,
                onConfirm: { viewModel.confirm() },
                onCancel: { viewModel.cancel() }
            )
            .padding(4)

        case .unsupportedClipboard(let types):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.orange)

                Text("Clipboard content is not editable as text")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)

                if !types.isEmpty {
                    Text("Detected types: \(types.prefix(3).joined(separator: ", "))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                Text("Original clipboard content remains intact.")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)

                Button("Dismiss (Esc)") {
                    viewModel.cancel()
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()

        case .emptyClipboard:
            VStack(spacing: 12) {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 32))
                    .foregroundStyle(.secondary)

                Text("Clipboard is empty")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)

                Text("Copy text in any app, then press ⌘⇧C to edit.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Button("Close (Esc)") {
                    viewModel.cancel()
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(.bordered)
                .controlSize(.small)
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()

        case .idle:
            Color.clear
        }
    }

    // MARK: - Footer
    private var footerView: some View {
        HStack(spacing: 8) {
            // Quick Transforms
            if viewModel.state == .editing {
                HStack(spacing: 4) {
                    ForEach(viewModel.transforms, id: \.id) { transform in
                        Button {
                            viewModel.applyTransform(transform)
                        } label: {
                            Text(transform.name)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .buttonStyle(.borderless)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color.primary.opacity(0.06))
                        )
                        .help("Apply \(transform.name)")
                    }
                }
            }

            // Feedback Toast
            if let feedback = viewModel.feedbackMessage {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.feedbackIsError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 11))
                    Text(feedback)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(viewModel.feedbackIsError ? Color.red : Color.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill((viewModel.feedbackIsError ? Color.red : Color.green).opacity(0.12))
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            Spacer()

            // Cancel Button
            Button {
                viewModel.cancel()
            } label: {
                Text("Esc Cancel")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            // Commit Button
            Button {
                viewModel.confirm()
            } label: {
                HStack(spacing: 4) {
                    Text("⌘↵ Copy")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.accentColor)
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.state != .editing)
            .opacity(viewModel.state == .editing ? 1.0 : 0.4)
            .help("Save edited text to clipboard (⌘+Enter)")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.02))
    }
}
