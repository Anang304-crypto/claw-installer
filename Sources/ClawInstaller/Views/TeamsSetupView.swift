// TeamsSetupView — Step-by-step Microsoft Teams Bot Setup

import SwiftUI

struct TeamsSetupView: View {
    let onComplete: () -> Void

    @StateObject private var configManager = ConfigManager.shared
    @State private var currentStep: Int = 0
    @State private var botToken: String = ""
    @State private var tenantId: String = ""
    @State private var isValidating: Bool = false
    @State private var validationError: String?
    @State private var isTokenValid: Bool = false

    private let steps = [
        SetupStep(
            title: "前往 Azure Portal",
            description: "登入 Microsoft Azure Portal，我們需要建立一個 Bot 資源。",
            action: "開啟 Azure Portal",
            link: "https://portal.azure.com/#create/Microsoft.AzureBot"
        ),
        SetupStep(
            title: "建立 Azure Bot",
            description: "1. 選擇「Azure Bot」資源\n2. 填寫 Bot handle（例如「openclaw-bot」）\n3. 選擇訂閱和資源群組\n4. 定價層選擇「F0（免費）」\n5. 點選「建立」",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "設定 Teams 頻道",
            description: "Bot 建立完成後：\n\n1. 前往 Bot 資源的「Channels」頁面\n2. 點選「Microsoft Teams」圖示\n3. 同意服務條款\n4. 點選「Apply」啟用 Teams 頻道",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "取得 Bot Token",
            description: "1. 前往 Bot 的「Configuration」頁面\n2. 找到「Microsoft App ID」\n3. 點選「Manage Password」\n4. 建立新的 Client Secret\n5. 複製 Secret Value（這就是 Bot Token）",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "取得 Tenant ID",
            description: "1. 前往 Azure Active Directory\n2. 在「Overview」頁面找到「Tenant ID」\n3. 複製這個 GUID 格式的 ID\n\n格式範例：xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
            action: nil,
            link: nil
        )
    ]

    // Teams brand color
    private let teamsColor = Color(red: 0.384, green: 0.392, blue: 0.655)

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

                    // Tenant ID input on step 4
                    if currentStep == 4 {
                        tenantIdInputView
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
                    .fill(index <= currentStep ? teamsColor : Color.secondary.opacity(0.3))
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
                .tint(teamsColor)
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
                    icon: "person.3.fill",
                    color: teamsColor,
                    title: "Microsoft Teams Bot",
                    description: "透過 Azure Bot Service 連結 Teams"
                )
                infoCard(
                    icon: "creditcard",
                    color: .green,
                    title: "免費方案可用",
                    description: "F0 定價層免費，每月 10,000 則訊息"
                )
            }

        case 2:
            VStack(alignment: .leading, spacing: 4) {
                checklistItem("啟用 Teams 頻道")
                checklistItem("同意服務條款")
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
            .foregroundStyle(teamsColor)
    }

    // MARK: - Bot Token Input

    private var botTokenInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bot Token (Client Secret)")
                .font(.headline)

            SecureField("貼上你的 Client Secret", text: $botToken)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            Text("在 Azure Bot 的「Manage Password」中產生的 Client Secret")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Tenant ID Input

    private var tenantIdInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tenant ID")
                .font(.headline)

            HStack {
                TextField("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", text: $tenantId)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))

                Button("驗證") {
                    validateInputs()
                }
                .disabled(botToken.isEmpty || tenantId.isEmpty || isValidating)
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
                Label("驗證成功！", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(teamsColor)
            }

            Text("GUID 格式，可在 Azure Active Directory 的 Overview 頁面找到")
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
                .tint(teamsColor)
            } else {
                Button("儲存並繼續") {
                    saveAndContinue()
                }
                .buttonStyle(.borderedProminent)
                .tint(teamsColor)
                .disabled(!isTokenValid)
            }
        }
        .padding()
    }

    // MARK: - Actions

    private func validateInputs() {
        isValidating = true
        validationError = nil
        isTokenValid = false

        // Validate bot token is non-empty
        let tokenValid = botToken.count >= 10

        // Validate tenant ID is GUID format
        let guidPattern = #"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"#
        let tenantValid = tenantId.range(of: guidPattern, options: .regularExpression) != nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isValidating = false

            if !tokenValid {
                validationError = "Bot Token 不能為空或太短"
            } else if !tenantValid {
                validationError = "Tenant ID 格式不正確，應為 GUID 格式（xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx）"
            } else {
                isTokenValid = true
            }
        }
    }

    private func saveAndContinue() {
        do {
            try configManager.setTeamsConfig(botToken: botToken, tenantId: tenantId)
            onComplete()
        } catch {
            validationError = "儲存失敗：\(error.localizedDescription)"
        }
    }
}
