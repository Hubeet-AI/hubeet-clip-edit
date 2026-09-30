import SwiftUI

/// Settings view providing configuration for shortcuts, launch behavior, and privacy policies.
public struct SettingsView: View {
    @StateObject private var launchManager = LaunchAtLoginManager()

    public init() {}

    public var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            privacyTab
                .tabItem {
                    Label("Privacy", systemImage: "hand.raised.fill")
                }

            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 480, height: 320)
        .padding()
    }

    // MARK: - General Tab
    private var generalTab: some View {
        Form {
            Section {
                HStack {
                    Text("Global Shortcut")
                    Spacer()
                    HStack(spacing: 4) {
                        Text("⌘")
                        Text("⇧")
                        Text("C")
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.primary.opacity(0.08))
                    )
                }

                Toggle("Launch at Login", isOn: Binding(
                    get: { launchManager.isEnabled },
                    set: { launchManager.setEnabled($0) }
                ))

                Picker("Window Position", selection: .constant(0)) {
                    Text("Active Screen (Cursor)").tag(0)
                }
                .disabled(true)
            } header: {
                Text("Activation & Window")
            }

            Section {
                HStack(alignment: .top) {
                    Image(systemName: "hand.tap")
                        .foregroundStyle(Color.accentColor)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Explicit Paste Model")
                            .font(.system(size: 12, weight: .medium))
                        Text("ClipEdit puts edited text in your clipboard and returns focus to your previous app. You paste explicitly with ⌘V.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Paste Behavior")
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Privacy Tab
    private var privacyTab: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.green)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("100% Local & Private")
                                .font(.system(size: 13, weight: .semibold))
                            Text("ClipEdit never sends data to any server. There is no telemetry, no tracking, and no network access.")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "memorychip")
                            .font(.system(size: 20))
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Zero Persistent Storage")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Clipboard content is only held in volatile memory while the editor window is open. Nothing is written to disk or logs.")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.teal)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("No Accessibility Permissions Required")
                                .font(.system(size: 13, weight: .semibold))
                            Text("ClipEdit uses native Carbon HotKeys and standard NSPasteboard APIs without needing Accessibility or Screen Recording privileges.")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - About Tab
    private var aboutTab: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 4) {
                Text("ClipEdit")
                    .font(.system(size: 18, weight: .bold))
                Text("Version 1.0.0")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Text("The ephemeral clipboard transformer between Copy and Paste.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Text("Designed for macOS 14+")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
