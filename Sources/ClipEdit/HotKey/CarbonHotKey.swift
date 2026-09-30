import Carbon
import Foundation

/// Low-level wrapper around the macOS Carbon `RegisterEventHotKey` API.
///
/// This mechanism allows global hotkey interception across all applications
/// without requiring Accessibility or Input Monitoring permissions.
public final class CarbonHotKey {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let id: UInt32
    private let keyCode: UInt32
    private let modifiers: UInt32
    private let action: @MainActor () -> Void

    public init(
        id: UInt32 = 1,
        keyCode: UInt32 = UInt32(kVK_ANSI_C),
        modifiers: UInt32 = UInt32(cmdKey | shiftKey),
        action: @escaping @MainActor () -> Void
    ) {
        self.id = id
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.action = action
    }

    deinit {
        unregister()
    }

    /// Registers the hotkey with Carbon.
    @discardableResult
    public func register() -> Bool {
        unregister()

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPointer = Unmanaged.passUnretained(self).toOpaque()

        let handlerStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, eventRef, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let hotKey = Unmanaged<CarbonHotKey>.fromOpaque(userData).takeUnretainedValue()
                hotKey.handleEvent(eventRef)
                return noErr
            },
            1,
            &eventType,
            selfPointer,
            &eventHandlerRef
        )

        guard handlerStatus == noErr else {
            return false
        }

        let hotKeyID = EventHotKeyID(signature: OSType(0x434C4544), id: id) // 'CLED'
        let registerStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        return registerStatus == noErr
    }

    /// Unregisters the hotkey and removes the event handler.
    public func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
            eventHandlerRef = nil
        }
    }

    private func handleEvent(_ eventRef: EventRef?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.action()
        }
    }
}
