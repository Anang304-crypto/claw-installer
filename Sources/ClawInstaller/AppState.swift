import Foundation
import SwiftUI

/// Shared app state across all views
@MainActor
final class AppState: ObservableObject {
    enum Step: Int, CaseIterable {
        case preflight = 0
        case install
        case channels
        case monitor
        case support
    }

    @Published var currentStep: Step = .preflight
    @Published var installProgress: Double = 0
    @Published var gatewayRunning: Bool = false
    @Published var isInstalling: Bool = false
    
    // Preflight results
    @Published var preflightChecker = PreflightChecker()

    // Telemetry opt-out
    @AppStorage("telemetryEnabled") var telemetryEnabled: Bool = true

    /// Fire-and-forget telemetry event
    func trackEvent(_ event: String, module: String, meta: [String: String]? = nil) {
        guard telemetryEnabled else { return }
        Task.detached {
            await BackendService.shared.sendTelemetryEvent(
                event: event,
                module: module,
                meta: meta,
                arch: await MainActor.run { self.preflightChecker.detectedArch },
                nodeVersion: await MainActor.run { self.preflightChecker.detectedNodeVersion },
                packageManager: await MainActor.run { self.preflightChecker.detectedPackageManager }
            )
        }
    }
}
