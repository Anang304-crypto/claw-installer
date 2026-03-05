// BackendService — HTTP client for claw-backend API
// Handles AI chat and telemetry event reporting

import Foundation
import CryptoKit

actor BackendService {
    static let shared = BackendService()

    private let baseURL: URL
    private let session = URLSession.shared
    private let deviceId: String

    init() {
        let urlString = ProcessInfo.processInfo.environment["CLAW_BACKEND_URL"]
            ?? "http://localhost:3200"
        self.baseURL = URL(string: urlString)!
        self.deviceId = BackendService.generateDeviceId()
    }

    // MARK: - AI Chat

    struct ChatRequest: Codable {
        let message: String
        let context: InstallContext?
        let history: [HistoryMessage]?
    }

    struct InstallContext: Codable {
        let nodeVersion: String?
        let packageManager: String?
        let arch: String?
        let preflightResults: [PreflightResult]?
        let installedVersion: String?
        let channels: [String]?
        let gatewayStatus: String?
    }

    struct PreflightResult: Codable {
        let name: String
        let status: String  // pass, fail, warn
        let detail: String?
    }

    struct HistoryMessage: Codable {
        let role: String  // user, assistant
        let content: String
    }

    struct ChatResponse: Codable {
        let response: String
        let usage: Usage?
        let model: String?
        let error: String?
    }

    struct Usage: Codable {
        let inputTokens: Int?
        let outputTokens: Int?
    }

    func sendMessage(
        message: String,
        context: InstallContext? = nil,
        history: [HistoryMessage]? = nil
    ) async throws -> String {
        let url = baseURL.appendingPathComponent("api/ai/chat")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body = ChatRequest(message: message, context: context, history: history)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }

        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)

        if let error = chatResponse.error {
            throw BackendError.serverError(error)
        }

        guard httpResponse.statusCode == 200 else {
            throw BackendError.serverError(chatResponse.error ?? "HTTP \(httpResponse.statusCode)")
        }

        return chatResponse.response
    }

    // MARK: - Telemetry

    struct TelemetryEvent: Codable {
        let deviceId: String
        let event: String
        let module: String
        let meta: [String: String]?
        let durationMs: Int?
        let arch: String?
        let macosVersion: String?
        let nodeVersion: String?
        let packageManager: String?
    }

    func sendTelemetryEvent(
        event: String,
        module: String,
        meta: [String: String]? = nil,
        durationMs: Int? = nil,
        arch: String? = nil,
        nodeVersion: String? = nil,
        packageManager: String? = nil
    ) async {
        let url = baseURL.appendingPathComponent("api/telemetry/event")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 5

        let macosVersion = ProcessInfo.processInfo.operatingSystemVersionString

        let body = TelemetryEvent(
            deviceId: deviceId,
            event: event,
            module: module,
            meta: meta,
            durationMs: durationMs,
            arch: arch,
            macosVersion: macosVersion,
            nodeVersion: nodeVersion,
            packageManager: packageManager
        )

        do {
            request.httpBody = try JSONEncoder().encode(body)
            let _ = try await session.data(for: request)
        } catch {
            // Telemetry is fire-and-forget, never block the user
        }
    }

    // MARK: - Status

    struct StatusResponse: Codable {
        let available: Bool
        let model: String?
    }

    func checkAvailability() async -> Bool {
        let url = baseURL.appendingPathComponent("api/ai/status")
        do {
            let (data, _) = try await session.data(from: url)
            let status = try JSONDecoder().decode(StatusResponse.self, from: data)
            return status.available
        } catch {
            return false
        }
    }

    // MARK: - Device ID

    private static func generateDeviceId() -> String {
        // SHA-256 hash of hardware UUID for anonymous device tracking
        let platform = ProcessInfo.processInfo.environment["__CF_USER_TEXT_ENCODING"] ?? "unknown"
        let host = ProcessInfo.processInfo.hostName
        let raw = "\(host)-\(platform)-clawinstaller"
        let hash = SHA256.hash(data: Data(raw.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Errors

enum BackendError: LocalizedError {
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "無法連接到伺服器"
        case .serverError(let message):
            return message
        }
    }
}
