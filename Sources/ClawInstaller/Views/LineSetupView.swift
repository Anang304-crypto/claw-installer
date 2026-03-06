// LineSetupView — Step-by-step LINE Messaging API Setup

import SwiftUI

struct LineSetupView: View {
    let onComplete: () -> Void

    @StateObject private var configManager = ConfigManager.shared
    @State private var currentStep: Int = 0
    @State private var channelAccessToken: String = ""
    @State private var channelSecret: String = ""
    @State private var isValidating: Bool = false
    @State private var validationError: String?
    @State private var isTokenValid: Bool = false

    private let steps = [
        SetupStep(
            title: "前往 LINE Developers",
            description: "登入 LINE Developers Console，使用你的 LINE 帳號登入。",
            action: "開啟 LINE Developers",
            link: "https://developers.line.biz/console/"
        ),
        SetupStep(
            title: "建立 Provider & Channel",
            description: "1. 點選「Create a new provider」\n2. 輸入 Provider 名稱（例如「OpenClaw」）\n3. 選擇「Create a Messaging API channel」\n4. 填寫 Channel 基本資訊（名稱、描述、分類）",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "取得 Channel Secret",
            description: "在 Channel 的「Basic settings」頁面中，找到「Channel secret」並複製。",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "取得 Channel Access Token",
            description: "在 Channel 的「Messaging API」頁面中：\n\n1. 捲動到最下方「Channel access token」\n2. 點選「Issue」產生 Long-lived token\n3. 複製產生的 token",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "關閉自動回覆",
            description: "在「Messaging API」頁面：\n\n1. 找到「Auto-reply messages」\n2. 點選「Edit」進入 LINE Official Account Manager\n3. 關閉「自動回應訊息」\n4. 開啟「Webhook」",
            action: nil,
            link: nil
        )
    ]

    // LINE brand color
    private let lineGreen = Color(red: 0.024, green: 0.780, blue: 0.333)

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

                    // Channel Secret input on step 2
                    if currentStep == 2 {
                        secretInputView
                    }

                    // Channel Access Token input on step 3
                    if currentStep == 3 {
                        tokenInputView
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
                    .fill(index <= currentStep ? lineGreen : Color.secondary.opacity(0.3))
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
                .tint(lineGreen)
            }
        }
    }

    // MARK: - Visual Hints

    @ViewBuilder
    private func visualHint(for step: Int) -> some View {
        switch step {
        case 0:
            VStack(spacing: 12) {
                infoCard(
                    icon: "message.fill",
                    color: lineGreen,
                    title: "Messaging API",
                    description: "LINE 官方提供的機器人框架"
                )
                infoCard(
                    icon: "person.2.fill",
                    color: .blue,
                    title: "免費方案可用",
                    description: "每月 500 則免費推播訊息"
                )
            }

        case 1:
            VStack(alignment: .leading, spacing: 4) {
                checklistItem("建立 Provider")
                checklistItem("建立 Messaging API Channel")
                checklistItem("填寫 Channel 基本資訊")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))

        case 4:
            VStack(alignment: .leading, spacing: 4) {
                checklistItem("關閉自動回應訊息")
                checklistItem("開啟 Webhook")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))

        default:
            EmptyView()
        }
    }

    private func infoCard(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func checklistItem(_ text: String) -> some View {
        Text("✓ \(text)")
            .font(.system(size: 13, design: .monospaced))
            .foregroundStyle(lineGreen)
    }

    // MARK: - Secret Input

    private var secretInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Channel Secret")
                .font(.headline)

            SecureField("貼上你的 Channel Secret", text: $channelSecret)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            Text("Channel Secret 可在「Basic settings」頁面找到")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Token Input

    private var tokenInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Channel Access Token")
                .font(.headline)

            HStack {
                SecureField("貼上你的 Channel Access Token", text: $channelAccessToken)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))

                Button("驗證") {
                    validateToken()
                }
                .disabled(channelAccessToken.isEmpty || isValidating)
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
                    .foregroundStyle(lineGreen)
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
                .tint(lineGreen)
            } else {
                Button("儲存並繼續") {
                    saveAndContinue()
                }
                .buttonStyle(.borderedProminent)
                .tint(lineGreen)
                .disabled(!isTokenValid || channelSecret.isEmpty)
            }
        }
        .padding()
    }

    // MARK: - Actions

    private func validateToken() {
        isValidating = true
        validationError = nil
        isTokenValid = false

        // LINE Channel Access Token is a long JWT-like string
        let isValidFormat = channelAccessToken.count >= 100

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isValidating = false

            if isValidFormat {
                isTokenValid = true
            } else {
                validationError = "Token 格式不正確。LINE Channel Access Token 通常是很長的字串。"
            }
        }
    }

    private func saveAndContinue() {
        do {
            try configManager.setLineConfig(
                channelAccessToken: channelAccessToken,
                channelSecret: channelSecret
            )
            onComplete()
        } catch {
            validationError = "儲存失敗：\(error.localizedDescription)"
        }
    }
}
