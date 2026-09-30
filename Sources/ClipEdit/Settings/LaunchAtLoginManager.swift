import Foundation
import ServiceManagement

/// Manages Launch at Login using modern macOS `SMAppService`.
@MainActor
public final class LaunchAtLoginManager: ObservableObject {
    @Published public var isEnabled: Bool = false

    public init() {
        updateStatus()
    }

    public func updateStatus() {
        self.isEnabled = (SMAppService.mainApp.status == .enabled)
    }

    public func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
            updateStatus()
        } catch {
            // ServiceManagement errors might occur in unsigned dev builds
            self.isEnabled = (SMAppService.mainApp.status == .enabled)
        }
    }
}
