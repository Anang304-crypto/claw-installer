// DiscordSetupView — Step-by-step Discord Bot Setup

import SwiftUI

struct DiscordSetupView: View {
    let onComplete: () -> Void

    @StateObject private var configManager = ConfigManager.shared
    @State private var currentStep: Int = 0
    @State private var botToken: String = ""
    @State private var applicationId: String = ""
    @State private var validationError: String?
    @State private var isTokenValid: Bool = false

    // Discord brand color
    private let discordColor = Color(red: 0.345, green: 0.396, blue: 0.949) // #5865F2

    private let steps = [
        SetupStep(
            title: "開啟 Discord Developer Portal",
            description: "前往 Discord Developer Portal，使用你的 Discord 帳號登入。",
            action: "開啟 Developer Portal",
            link: "https://discord.com/developers/applications"
        ),
        SetupStep(
            title: "建立新 Application",
            description: "點擊右上角的「New Application」：\n\n1. 輸入名稱（例如「OpenClaw Bot」）\n2. 同意條款並點選「Create」",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "建立 Bot 使用者",
            description: "在 Application 設定中：\n\n1. 點選左側的「Bot」\n2. 點選「Add Bot」→「Yes, do it!」\n3. 在「Privileged Gateway Intents」下啟用：\n   • Message Content Intent",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "複製 Bot Token",
            description: "在 Bot 頁面中：\n\n1. 點選「Reset Token」（或「View Token」）\n2. 複製 Token — 只會顯示一次！",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "取得 Application ID",
            description: "前往左側的「General Information」，複製 Application ID。",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "邀請 Bot 到伺服器",
            description: "使用下方連結將 Bot 邀請到你的 Discord 伺服器。選擇伺服器後授權即可。",
            action: nil,
            link: nil
        )
    ]

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

                    // Token input on step 3
                    if currentStep == 3 {
                        tokenInputView
                    }

                    // App ID input on step 4
                    if currentStep == 4 {
                        appIdInputView
                    }

                    // Invite link on step 5
                    if currentStep == 5 {
                        inviteLinkView
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
                    .fill(index <= currentStep ? discordColor : Color.secondary.opacity(0.3))
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
                .tint(discordColor)
            }
        }
    }

    // MARK: - Visual Hints

    @ViewBuilder
    private func visualHint(for step: Int) -> some View {
        switch step {
        case 2:
            VStack(alignment: .leading, spacing: 4) {
                checklistItem("Bot 已建立")
                checklistItem("Message Content Intent 已啟用")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))

        default:
            EmptyView()
        }
    }

    private func checklistItem(_ text: String) -> some View {
        Text("✓ \(text)")
            .font(.system(size: 13, design: .monospaced))
            .foregroundStyle(discordColor)
    }

    // MARK: - Token Input

    private var tokenInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bot Token")
                .font(.headline)

            SecureField("貼上你的 Bot Token", text: $botToken)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            Text("請妥善保管此 Token，任何擁有它的人都能控制你的 Bot。")
                .font(.caption)
                .foregroundStyle(.orange)
        }
    }

    // MARK: - App ID Input

    private var appIdInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Application ID")
                .font(.headline)

            TextField("例如 1234567890123456789", text: $applicationId)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            if let error = validationError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Text("在「General Information」頁面中找到的 17-19 位數字")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Invite Link

    private var inviteLinkView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !applicationId.isEmpty {
                let inviteURL = "https://discord.com/api/oauth2/authorize?client_id=\(applicationId)&permissions=274877958144&scope=bot"

                Text("邀請連結：")
                    .font(.headline)

                Text(inviteURL)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Link(destination: URL(string: inviteURL)!) {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text("開啟邀請連結")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(discordColor)
            } else {
                Text("請先在上一步輸入 Application ID")
                    .foregroundStyle(.secondary)
            }
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
                .tint(discordColor)
            } else {
                Button("儲存並繼續") {
                    saveAndContinue()
                }
                .buttonStyle(.borderedProminent)
                .tint(discordColor)
                .disabled(botToken.isEmpty || applicationId.isEmpty)
            }
        }
        .padding()
    }

    // MARK: - Actions

    private func saveAndContinue() {
        // Validate app ID format
        guard applicationId.allSatisfy({ $0.isNumber }), applicationId.count >= 17 else {
            validationError = "Application ID 應為 17-19 位數字"
            return
        }

        do {
            try configManager.setDiscordConfig(botToken: botToken, applicationId: applicationId)
            onComplete()
        } catch {
            validationError = "儲存失敗：\(error.localizedDescription)"
        }
    }
}
