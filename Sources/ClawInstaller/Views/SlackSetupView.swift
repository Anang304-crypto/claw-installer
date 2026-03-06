// SlackSetupView — Step-by-step Slack Bot Setup

import SwiftUI

struct SlackSetupView: View {
    let onComplete: () -> Void

    @StateObject private var configManager = ConfigManager.shared
    @State private var currentStep: Int = 0
    @State private var botToken: String = ""
    @State private var appToken: String = ""
    @State private var isValidating: Bool = false
    @State private var validationError: String?
    @State private var isTokenValid: Bool = false

    private let steps = [
        SetupStep(
            title: "前往 Slack API",
            description: "登入 Slack API 網站，建立新的 App。",
            action: "開啟 Slack API",
            link: "https://api.slack.com/apps"
        ),
        SetupStep(
            title: "建立 Slack App",
            description: "1. 點選「Create New App」\n2. 選擇「From scratch」\n3. 輸入 App 名稱（例如「OpenClaw」）\n4. 選擇你的 Workspace\n5. 點選「Create App」",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "設定 Bot 權限",
            description: "在左側選單選擇「OAuth & Permissions」：\n\n捲動到「Scopes」→「Bot Token Scopes」，新增：\n• chat:write\n• channels:read\n• im:read\n• im:write\n• im:history",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "安裝到 Workspace",
            description: "1. 回到「OAuth & Permissions」頁面頂部\n2. 點選「Install to Workspace」\n3. 授權後，複製「Bot User OAuth Token」\n   （以 xoxb- 開頭）",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "取得 App-Level Token",
            description: "1. 前往「Basic Information」頁面\n2. 捲動到「App-Level Tokens」\n3. 點選「Generate Token and Scopes」\n4. 輸入名稱，新增 scope：connections:write\n5. 點選「Generate」，複製 token（以 xapp- 開頭）",
            action: nil,
            link: nil
        )
    ]

    // Slack brand color
    private let slackPink = Color(red: 0.878, green: 0.118, blue: 0.353)

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            progressBar

            // Step content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if currentStep < steps.count {
                        stepView(steps[currentStep])
                    }

                    // Bot Token input on step 3
                    if currentStep == 3 {
                        botTokenInputView
                    }

                    // App Token input on step 4
                    if currentStep == 4 {
                        appTokenInputView
                    }

                    // Visual hints
                    visualHint(for: currentStep)
                }
                .padding(24)
            }

            Divider()

            // Navigation
            navigationBar
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<steps.count, id: \.self) { index in
                Rectangle()
                    .fill(index <= currentStep ? slackPink : Color.secondary.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Step View

    private func stepView(_ step: SetupStep) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Step \(currentStep + 1)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary)
                    .clipShape(Capsule())

                Spacer()
            }

            Text(step.title)
                .font(.title2.bold())

            Text(step.description)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let action = step.action, let link = step.link {
                Link(destination: URL(string: link)!) {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text(action)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(slackPink)
            }
        }
    }

    // MARK: - Visual Hints

    @ViewBuilder
    private func visualHint(for step: Int) -> some View {
        switch step {
        case 2:
            VStack(alignment: .leading, spacing: 4) {
                Text("需要的 Bot Token Scopes：")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                scopeItem("chat:write")
                scopeItem("channels:read")
                scopeItem("im:read")
                scopeItem("im:write")
                scopeItem("im:history")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))

        default:
            EmptyView()
        }
    }

    private func scopeItem(_ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 10))
                .foregroundStyle(slackPink)
            Text(text)
                .font(.system(size: 12, design: .monospaced))
        }
    }

    // MARK: - Bot Token Input

    private var botTokenInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bot User OAuth Token")
                .font(.headline)

            SecureField("xoxb-...", text: $botToken)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            Text("以 xoxb- 開頭的 Bot Token")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - App Token Input

    private var appTokenInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App-Level Token")
                .font(.headline)

            HStack {
                SecureField("xapp-...", text: $appToken)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))

                Button("驗證") {
                    validateTokens()
                }
                .disabled(botToken.isEmpty || appToken.isEmpty || isValidating)
            }

            if isValidating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("驗證中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = validationError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if isTokenValid {
                Label("Token 驗證成功！", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(slackPink)
            }

            Text("以 xapp- 開頭的 App-Level Token（用於 Socket Mode）")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Navigation

    private var navigationBar: some View {
        HStack {
            if currentStep > 0 {
                Button("上一步") {
                    currentStep -= 1
                }
            }

            Spacer()

            if currentStep < steps.count - 1 {
                Button("下一步") {
                    currentStep += 1
                }
                .buttonStyle(.borderedProminent)
                .tint(slackPink)
            } else {
                Button("儲存並繼續") {
                    saveAndContinue()
                }
                .buttonStyle(.borderedProminent)
                .tint(slackPink)
                .disabled(!isTokenValid)
            }
        }
        .padding()
    }

    // MARK: - Actions

    private func validateTokens() {
        isValidating = true
        validationError = nil
        isTokenValid = false

        let botValid = botToken.hasPrefix("xoxb-") && botToken.count > 20
        let appValid = appToken.hasPrefix("xapp-") && appToken.count > 20

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isValidating = false

            if !botValid {
                validationError = "Bot Token 格式不正確，應以 xoxb- 開頭"
            } else if !appValid {
                validationError = "App Token 格式不正確，應以 xapp- 開頭"
            } else {
                isTokenValid = true
            }
        }
    }

    private func saveAndContinue() {
        do {
            try configManager.setSlackConfig(botToken: botToken, appToken: appToken)
            onComplete()
        } catch {
            validationError = "儲存失敗：\(error.localizedDescription)"
        }
    }
}
