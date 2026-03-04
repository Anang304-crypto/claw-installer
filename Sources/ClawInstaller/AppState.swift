import Foundation

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
    @Published var preflightResults: [PreflightCheck] = []
    @Published var installProgress: Double = 0
    @Published var gatewayRunning: Bool = false
    @Published var isInstalling: Bool = false
}

struct PreflightCheck: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    var status: Status
    var detail: String?
    var fixAction: String? // shell command to fix

    enum Status {
        case pass, fail, warn, checking
    }
}
