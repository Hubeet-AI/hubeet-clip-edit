import Carbon
import Foundation

/// Protocol defining the interface for global hotkey management.
public protocol HotKeyManaging: AnyObject {
    var isRegistered: Bool { get }
    func registerDefault(action: @escaping @MainActor () -> Void) -> Bool
    func registerCustom(keyCode: UInt32, modifiers: UInt32, action: @escaping @MainActor () -> Void) -> Bool
    func unregister()
}

/// Central manager for the global shortcut (default: ⌘⇧C).
///
/// Uses Carbon Event HotKeys to provide system-wide interception without
/// requiring Accessibility permissions.
public final class HotKeyManager: HotKeyManaging {
    private var hotKey: CarbonHotKey?
    public private(set) var isRegistered: Bool = false

    public init() {}

    deinit {
        unregister()
    }

    /// Registers the default shortcut: ⌘ + ⇧ + C.
    @discardableResult
    public func registerDefault(action: @escaping @MainActor () -> Void) -> Bool {
        return registerCustom(
            keyCode: UInt32(kVK_ANSI_C),
            modifiers: UInt32(cmdKey | shiftKey),
            action: action
        )
    }

    /// Registers a custom hotkey combination.
    @discardableResult
    public func registerCustom(keyCode: UInt32, modifiers: UInt32, action: @escaping @MainActor () -> Void) -> Bool {
        unregister()

        let newHotKey = CarbonHotKey(
            id: 1,
            keyCode: keyCode,
            modifiers: modifiers,
            action: action
        )

        let success = newHotKey.register()
        if success {
            self.hotKey = newHotKey
            self.isRegistered = true
        }
        return success
    }

    /// Unregisters any currently active hotkey.
    public func unregister() {
        hotKey?.unregister()
        hotKey = nil
        isRegistered = false
    }
}
