import SwiftUI

struct PreflightView: View {
    @StateObject private var checker = PreflightChecker()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Environment Check")
                .font(.title.bold())

            Text("Checking your system for OpenClaw prerequisites...")
                .foregroundStyle(.secondary)

            if checker.checks.isEmpty {
                Button("Run Checks") {
                    Task { await checker.runAll() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                List(checker.checks) { check in
                    HStack {
                        statusIcon(check.status)
                        VStack(alignment: .leading) {
                            Text(check.name).font(.headline)
                            if let detail = check.detail {
                                Text(detail).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if check.fixAction != nil && check.status == .fail {
                            Button("Fix") {
                                // TODO: execute fix action
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                    .padding(.vertical, 4)
                }

                if !checker.isRunning {
                    Button("Re-check") {
                        Task { await checker.runAll() }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .task {
            await checker.runAll()
        }
    }

    @ViewBuilder
    private func statusIcon(_ status: PreflightCheck.Status) -> some View {
        switch status {
        case .pass:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .fail:
            Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
        case .warn:
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
        case .checking:
            ProgressView().controlSize(.small)
        }
    }
}
