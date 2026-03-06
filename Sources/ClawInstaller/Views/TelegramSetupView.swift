// TelegramSetupView — Step-by-step Telegram Bot Setup

import SwiftUI

struct TelegramSetupView: View {
    let onComplete: () -> Void

    @StateObject private var configManager = ConfigManager.shared
    @State private var currentStep: Int = 0
    @State private var botToken: String = ""
    @State private var isValidating: Bool = false
    @State private var validationError: String?
    @State private var isTokenValid: Bool = false

    // Telegram brand color
    private let telegramColor = Color(red: 0.0, green: 0.533, blue: 0.8) // #0088CC

    private let steps = [
        SetupStep(
            title: "開啟 BotFather",
            description: "開啟 Telegram 並搜尋 @BotFather，或點擊下方連結。",
            action: "開啟 BotFather",
            link: "https://t.me/BotFather"
        ),
        SetupStep(
            title: "建立新 Bot",
            description: "傳送 /newbot 給 BotFather，然後依照提示操作：\n\n1. 輸入一個顯示名稱（例如「My OpenClaw」）\n2. 輸入一個以 'bot' 結尾的使用者名稱（例如「my_openclaw_bot」）",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "複製 Bot Token",
            description: "BotFather 會給你一組 Token（如 123456789:ABCdef...），複製後貼到下方欄位。",
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
                VStack(alignment: .leading, spacing: 14) {
                    if currentStep < steps.count {
                        stepView(steps[currentStep])
                    }

                    // Token input on last step
                    if currentStep == 2 {
                        tokenInputView
                    }
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
                    .fill(index <= currentStep ? telegramColor : Color.secondary.opacity(0.3))
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
                .tint(telegramColor)
            }

            // Visual hints
            screenshotPlaceholder(for: currentStep)
        }
    }

    @ViewBuilder
    private func screenshotPlaceholder(for step: Int) -> some View {
        VStack {
            switch step {
            case 0:
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("在 Telegram 中搜尋 @BotFather")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            case 1:
                VStack(alignment: .leading, spacing: 8) {
                    mockChatBubble(isBot: false, text: "/newbot")
                    mockChatBubble(isBot: true, text: "好的，讓我們建立新的 Bot。請選擇一個名稱。")
                    mockChatBubble(isBot: false, text: "My OpenClaw")
                    mockChatBubble(isBot: true, text: "很好。現在請選擇一個使用者名稱...")
                }
            case 2:
                // BotFather guide screenshot (phone, already has red circle)
                if let url = Bundle.module.url(forResource: "botfather_guide", withExtension: "jpg"),
                   let nsImage = NSImage(contentsOf: url) {
                    VStack(spacing: 6) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                            )

                        Text("複製紅圈內的 Token 貼到下方")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func mockChatBubble(isBot: Bool, text: String) -> some View {
        HStack {
            if !isBot { Spacer() }

            Text(text)
                .font(.system(size: 13))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isBot ? Color.secondary.opacity(0.2) : telegramColor)
                .foregroundColor(isBot ? .primary : .white)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if isBot { Spacer() }
        }
    }

    // MARK: - Token Input

    private var tokenInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bot Token")
                .font(.headline)

            HStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    if botToken.isEmpty {
                        Text("貼上你的 Bot Token")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                    TextField("", text: $botToken)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .monospaced))
                }
                .padding(10)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                )

                Button("驗證") {
                    validateToken()
                }
                .disabled(botToken.isEmpty || isValidating)
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
                    .foregroundStyle(telegramColor)
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
                .tint(telegramColor)
            } else {
                Button("儲存並繼續") {
                    saveAndContinue()
                }
                .buttonStyle(.borderedProminent)
                .tint(telegramColor)
                .disabled(!isTokenValid)
            }
        }
        .padding()
    }

    // MARK: - Actions

    private func validateToken() {
        isValidating = true
        validationError = nil
        isTokenValid = false

        // Basic format validation
        let tokenPattern = #"^\d+:[A-Za-z0-9_-]{35,}$"#
        let isValidFormat = botToken.range(of: tokenPattern, options: .regularExpression) != nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isValidating = false

            if isValidFormat {
                isTokenValid = true
            } else {
                validationError = "Token 格式不正確，應如 123456789:ABCdef..."
            }
        }
    }

    private func saveAndContinue() {
        do {
            try configManager.setTelegramToken(botToken)
            onComplete()
        } catch {
            validationError = "儲存失敗：\(error.localizedDescription)"
        }
    }
}

struct SetupStep {
    let title: String
    let description: String
    let action: String?
    let link: String?
}
