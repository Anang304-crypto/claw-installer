// LLMSetupView — AI Provider Setup (matches OpenClaw two-layer onboard flow)
// Flow: selectProvider → selectAuth → enterSecret → selectModel → validating → complete

import SwiftUI

struct LLMSetupView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = LLMSetupViewModel()
    var onComplete: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch viewModel.currentStep {
                case .selectProvider:
                    providerSelectionView
                case .selectAuth:
                    authSelectionView
                case .enterSecret:
                    enterSecretView
                case .selectModel:
                    modelSelectionView
                case .validating:
                    validatingView
                case .complete:
                    completeView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .windowBackgroundColor))

            if viewModel.currentStep != .selectProvider {
                Divider()
                footerView
            }
        }
    }

    // MARK: - Provider Selection

    private var providerSelectionView: some View {
        VStack(spacing: 0) {
            // Step indicator + progress bar
            VStack(alignment: .leading, spacing: 8) {
                Text("5 / 7")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 4)
                        Capsule()
                            .fill(Color.orange)
                            .frame(width: geo.size.width * (5.0 / 7.0), height: 4)
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal, 40)
            .padding(.top, 24)

            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text("選擇你的 AI 供應商")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)

                Text("OpenClaw 支援多個 Provider，選一個開始吧")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .padding(.horizontal, 40)

            // Provider list
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {

                    // Tier 1: Mainstream
                    tierHeader(.mainstream)
                    VStack(spacing: 8) {
                        ForEach(LLMProvider.providers(for: .mainstream)) { provider in
                            providerCard(provider)
                        }
                    }

                    // Tier 2: Asia
                    tierHeader(.asia)
                    asiaInfoTip
                    VStack(spacing: 8) {
                        ForEach(LLMProvider.providers(for: .asia)) { provider in
                            providerCard(provider)
                        }
                    }

                    // Mascot tip
                    mascotTipView

                    // Skip
                    Button {
                        appState.trackEvent("llm_setup_skip", module: "llm")
                        onComplete?()
                    } label: {
                        Text("略過 — 稍後再設定")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Tier Header

    private func tierHeader(_ tier: ProviderTier) -> some View {
        HStack(spacing: 6) {
            Text(tier.sectionIcon)
                .font(.system(size: 12))
            Text(tier.displayName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    // MARK: - Provider Card

    private func providerCard(_ provider: LLMProvider) -> some View {
        Button {
            viewModel.selectProvider(provider)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: provider.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(provider.color)
                    .frame(width: 36, height: 36)
                    .background(provider.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(provider.displayName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.primary)
                        Text(provider.modelName)
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }

                    Text(provider.tagline)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let badge = provider.badgeText {
                    Text(badge)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(provider.badgeColor)
                        .clipShape(Capsule())
                } else {
                    Text("設定 \u{2192}")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        provider == .anthropic ? Color.orange : Color(nsColor: .separatorColor),
                        lineWidth: provider == .anthropic ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Asia Info Tip

    private var asiaInfoTip: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.system(size: 11))
                .foregroundStyle(.blue)
            Text("這些模型性能優秀且價格實惠，適合高頻使用場景")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.blue.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - Mascot Tip

    private var mascotTipView: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 18))
                .foregroundStyle(.orange)
                .frame(width: 32, height: 32)
                .background(Color.orange.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text("不確定選哪個？推薦 **Anthropic**，Agent 表現最好！想省錢可選免費的 **Google**。")
                .font(.system(size: 11))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(red: 1.0, green: 0.973, blue: 0.941))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 1.0, green: 0.878, blue: 0.698), lineWidth: 1)
        )
    }

    // MARK: - Auth Selection (Layer 2 — matches OpenClaw AUTH_CHOICE_GROUP_DEFS)

    private var authSelectionView: some View {
        VStack(spacing: 0) {
            if let provider = viewModel.selectedProvider {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Back to provider list
                        Button {
                            viewModel.currentStep = .selectProvider
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("返回")
                            }
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)

                        // Provider header
                        HStack(spacing: 12) {
                            Image(systemName: provider.iconName)
                                .font(.system(size: 22))
                                .foregroundStyle(provider.color)
                                .frame(width: 44, height: 44)
                                .background(provider.color.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(provider.displayName)
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                Text("選擇驗證方式")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Auth choices
                        VStack(spacing: 8) {
                            ForEach(provider.authChoices) { choice in
                                authChoiceCard(choice, provider: provider)
                            }
                        }

                        // Setup steps for selected auth choice
                        if let choice = viewModel.selectedAuthChoice {
                            let steps = provider.setupSteps(for: choice)
                            if !steps.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("設定步驟")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.secondary)

                                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                                        HStack(alignment: .top, spacing: 10) {
                                            Text("\(index + 1)")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundStyle(.white)
                                                .frame(width: 20, height: 20)
                                                .background(provider.color)
                                                .clipShape(Circle())

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(step.title)
                                                    .font(.system(size: 12, weight: .semibold))
                                                Text(step.description)
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(.secondary)

                                                if let action = step.action, let url = step.url {
                                                    Link(destination: url) {
                                                        HStack(spacing: 4) {
                                                            Text(action)
                                                            Image(systemName: "arrow.up.right")
                                                        }
                                                        .font(.system(size: 11, weight: .medium))
                                                        .foregroundStyle(provider.color)
                                                    }
                                                    .padding(.top, 2)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(14)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(24)
                }
            }
        }
    }

    private func authChoiceCard(_ choice: AuthChoice, provider: LLMProvider) -> some View {
        let isSelected = viewModel.selectedAuthChoice?.id == choice.id

        return Button {
            viewModel.selectedAuthChoice = choice
        } label: {
            HStack(spacing: 12) {
                // Radio indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? provider.color : Color.secondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 18, height: 18)
                    if isSelected {
                        Circle()
                            .fill(provider.color)
                            .frame(width: 10, height: 10)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(choice.label)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)

                        if choice.isRecommended {
                            Text("推薦")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(provider.color)
                                .clipShape(Capsule())
                        }
                    }

                    if let hint = choice.hint {
                        Text(hint)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(isSelected ? provider.color.opacity(0.06) : Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? provider.color : Color(nsColor: .separatorColor),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Enter Secret (API Key, Setup Token, or OAuth status)

    private var enterSecretView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let provider = viewModel.selectedProvider,
                   let authChoice = viewModel.selectedAuthChoice {

                    // OAuth flow — show status instead of input
                    if authChoice.method == .deviceCode || authChoice.method == .oauth {
                        oauthStatusView(provider: provider, authChoice: authChoice)
                    } else {
                        secretInputView(provider: provider, authChoice: authChoice)
                    }
                }
            }
            .padding(24)
        }
    }

    private func oauthStatusView(provider: LLMProvider, authChoice: AuthChoice) -> some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(provider.color)
                    Text("OAuth 帳號授權")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                }

                Text(authChoice.hint ?? "使用帳號登入授權")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            // Existing config detected banner
            if viewModel.existingLLMDetected {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("已偵測到現有 AI 設定")
                            .font(.system(size: 12, weight: .semibold))
                        Text("目前設定：\(viewModel.existingLLMSummary)。重新設定將覆蓋現有配置。")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button("跳過") {
                        viewModel.currentStep = .selectModel
                    }
                    .font(.system(size: 11, weight: .medium))
                    .buttonStyle(.bordered)
                }
                .padding(12)
                .background(Color.blue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Result summary card (shown after completion)
            if !viewModel.oauthRunning, viewModel.cliExitCode != nil {
                resultSummaryCard(provider: provider)
            }

            // Inline terminal output
            VStack(alignment: .leading, spacing: 0) {
                // Terminal title bar
                HStack(spacing: 6) {
                    Circle().fill(
                        viewModel.cliExitCode != nil && !viewModel.cliSucceeded ? .red.opacity(0.8) :
                        viewModel.cliSucceeded ? .green.opacity(0.8) : .secondary.opacity(0.4)
                    ).frame(width: 10, height: 10)
                    Circle().fill(
                        viewModel.oauthRunning ? .yellow.opacity(0.8) : .secondary.opacity(0.4)
                    ).frame(width: 10, height: 10)
                    Circle().fill(
                        viewModel.cliSucceeded ? .green.opacity(0.8) : .secondary.opacity(0.4)
                    ).frame(width: 10, height: 10)

                    Spacer()

                    // Status text in title bar
                    if viewModel.oauthRunning {
                        HStack(spacing: 4) {
                            ProgressView()
                                .scaleEffect(0.4)
                                .frame(width: 10, height: 10)
                            Text("執行中...")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    } else {
                        Text("openclaw onboard")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    Spacer()

                    // Copy command button
                    Button {
                        let cmd = viewModel.oauthCommand()
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(cmd, forType: .string)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .buttonStyle(.borderless)
                    .help("複製指令")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(red: 0.18, green: 0.18, blue: 0.20))

                // Pinned command bar
                HStack(spacing: 8) {
                    Text(">_")
                        .font(.custom("JetBrains Mono", size: 11).bold())
                        .foregroundStyle(.green.opacity(0.9))
                    Text(viewModel.oauthCommand())
                        .font(.custom("JetBrains Mono", size: 12))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer()
                    if viewModel.cliSucceeded {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.green)
                    } else if viewModel.cliExitCode != nil {
                        Text("exit \(viewModel.cliExitCode!)")
                            .font(.custom("JetBrains Mono", size: 10))
                            .foregroundStyle(.red.opacity(0.8))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(red: 0.13, green: 0.13, blue: 0.15))

                // Terminal output area
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(Array(viewModel.parsedCLILines.enumerated()), id: \.offset) { index, parsed in
                                Text(parsed.text)
                                    .font(.custom("JetBrains Mono", size: 12))
                                    .foregroundStyle(parsed.color)
                                    .textSelection(.enabled)
                                    .id(index)
                            }

                            if viewModel.oauthRunning {
                                HStack(spacing: 4) {
                                    Text("\u{258B}")
                                        .font(.custom("JetBrains Mono", size: 12))
                                        .foregroundStyle(.green)
                                        .opacity(0.8)
                                }
                                .id("cursor")
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 160, maxHeight: 220)
                    .background(Color(red: 0.09, green: 0.09, blue: 0.11))
                    .onChange(of: viewModel.cliOutputLines.count) {
                        withAnimation(.easeOut(duration: 0.1)) {
                            if viewModel.oauthRunning {
                                proxy.scrollTo("cursor", anchor: .bottom)
                            } else if let last = viewModel.parsedCLILines.indices.last {
                                proxy.scrollTo(last, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )

            // Google Gemini CLI caution
            if authChoice.id == "google-gemini-cli" {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.orange)
                    Text("Google Gemini CLI OAuth 為非官方整合，部分用戶反映帳號有被限制的風險。")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            // Action row
            HStack(spacing: 12) {
                if !viewModel.oauthRunning {
                    Button {
                        viewModel.runOAuthInline()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text(viewModel.cliExitCode == nil ? "啟動" : "重新執行")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Text("也可在終端機手動執行")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    /// Result summary card — shows clear success/failure after CLI completes
    private func resultSummaryCard(provider: LLMProvider) -> some View {
        HStack(spacing: 12) {
            if viewModel.cliSucceeded {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text("授權設定成功")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("點擊「繼續」選擇模型")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.red)

                VStack(alignment: .leading, spacing: 2) {
                    Text("執行失敗")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.primary)
                    // Extract key error message
                    Text(viewModel.cliErrorSummary)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(viewModel.cliSucceeded ? Color.green.opacity(0.08) : Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(viewModel.cliSucceeded ? Color.green.opacity(0.2) : Color.red.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func secretInputView(provider: LLMProvider, authChoice: AuthChoice) -> some View {
        // Existing config detected banner
        if viewModel.existingLLMDetected {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text("已偵測到現有 AI 設定")
                        .font(.system(size: 12, weight: .semibold))
                    Text("目前設定：\(viewModel.existingLLMSummary)。輸入新金鑰將覆蓋現有配置。")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("跳過") {
                    viewModel.currentStep = .selectModel
                }
                .font(.system(size: 11, weight: .medium))
                .buttonStyle(.bordered)
            }
            .padding(12)
            .background(Color.blue.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }

        // Header
        VStack(spacing: 8) {
            Image(systemName: authChoice.method == .setupToken ? "ticket.fill" : "key.fill")
                .font(.system(size: 40))
                .foregroundStyle(provider.color)

            Text(authChoice.method == .setupToken ? "貼上 Setup Token" : "輸入 API 金鑰")
                .font(.system(size: 20, weight: .bold, design: .monospaced))

            if let hint = authChoice.hint {
                Text(hint)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, 4)

                    // Secret input card
                    VStack(alignment: .leading, spacing: 12) {
                        Text(authChoice.method == .setupToken ? "Token" : "API 金鑰")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)

                        // Use NSTextField-backed input for reliable paste support
                        HStack(spacing: 8) {
                            ZStack(alignment: .leading) {
                                if viewModel.secretInput.isEmpty {
                                    Text(authChoice.method == .setupToken ? "在此貼上 token..." : "在此貼上 API 金鑰...")
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundStyle(.tertiary)
                                }
                                TextField("", text: $viewModel.secretInput)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 13, design: .monospaced))
                            }

                            Button {
                                viewModel.showKey.toggle()
                            } label: {
                                Image(systemName: viewModel.showKey ? "eye.slash" : "eye")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(12)
                        .background(Color(nsColor: .textBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                        )

                        // Validation hint
                        HStack(spacing: 6) {
                            if viewModel.secretInput.isEmpty {
                                if authChoice.method == .setupToken {
                                    Image(systemName: "info.circle")
                                        .foregroundStyle(.secondary)
                                    Text("在終端機執行 claude setup-token 取得")
                                        .foregroundStyle(.secondary)
                                } else if !provider.keyPrefix.isEmpty {
                                    Image(systemName: "info.circle")
                                        .foregroundStyle(.secondary)
                                    Text("開頭為 \(provider.keyPrefix)...")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Image(systemName: "info.circle")
                                        .foregroundStyle(.secondary)
                                    Text("請輸入你的 API 金鑰")
                                        .foregroundStyle(.secondary)
                                }
                            } else if provider.validateInput(viewModel.secretInput, authChoice: authChoice) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text(authChoice.method == .setupToken ? "Token 格式正確" : "金鑰格式正確")
                                    .foregroundStyle(.green)
                            } else {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                if authChoice.method == .apiKey && !provider.keyPrefix.isEmpty {
                                    Text("金鑰應以 \(provider.keyPrefix) 開頭")
                                        .foregroundStyle(.orange)
                                } else {
                                    Text("格式不正確")
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                        .font(.caption)
                    }
                    .padding(16)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                    )

                    // Error message
                    if let error = viewModel.validationError {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                            Text(error)
                        }
                        .font(.caption)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Help link
                    if authChoice.method == .apiKey, let url = provider.apiKeyURL {
                        Link(destination: url) {
                            HStack(spacing: 4) {
                                Image(systemName: "questionmark.circle")
                                Text("哪裡取得 API 金鑰？")
                            }
                            .font(.caption)
                        }
                    }
    }

    // MARK: - Model Selection (matches OpenClaw model allowlist)

    private var modelSelectionView: some View {
        VStack(spacing: 0) {
            if let provider = viewModel.selectedProvider {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("選擇模型")
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                            Text("選擇 \(provider.displayName) 的預設模型，稍後可在設定中更改")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }

                        // Model options
                        VStack(spacing: 8) {
                            ForEach(provider.modelOptions) { model in
                                modelOptionCard(model, provider: provider)
                            }
                        }

                        // Failover toggle
                        if let failover = provider.failoverModel {
                            Button {
                                viewModel.enableFailover.toggle()
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: viewModel.enableFailover ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 16))
                                        .foregroundStyle(viewModel.enableFailover ? provider.color : .secondary)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("設定備援模型（選填）")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.primary)
                                        Text("當主模型不可用時自動切換到 \(failover.displayName)（\(failover.hint ?? "")）")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(24)
                }
            }
        }
    }

    private func modelOptionCard(_ model: ModelOption, provider: LLMProvider) -> some View {
        let isSelected = viewModel.selectedModel?.id == model.id

        return Button {
            viewModel.selectedModel = model
        } label: {
            HStack(spacing: 12) {
                // Radio
                ZStack {
                    Circle()
                        .stroke(isSelected ? provider.color : Color.secondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 18, height: 18)
                    if isSelected {
                        Circle()
                            .fill(provider.color)
                            .frame(width: 10, height: 10)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(model.displayName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)

                        if model.isDefault {
                            Text("預設")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(provider.color)
                                .clipShape(Capsule())
                        }
                    }

                    if let hint = model.hint {
                        Text(hint)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(model.id)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(isSelected ? provider.color.opacity(0.06) : Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? provider.color : Color(nsColor: .separatorColor),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Validating View

    private var validatingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)

            Text("驗證中...")
                .font(.headline)

            if let provider = viewModel.selectedProvider {
                Text("正在測試與 \(provider.displayName) 的連線")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Complete View

    private var completeView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.green)
            }

            VStack(spacing: 8) {
                Text("AI 供應商設定完成！")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))

                if let model = viewModel.selectedModel {
                    Text("\(model.displayName) 已準備就緒")
                        .foregroundStyle(.secondary)
                }
            }

            // Config summary
            if let provider = viewModel.selectedProvider {
                VStack(spacing: 12) {
                    configRow("供應商", provider.displayName)
                    Divider()
                    if let model = viewModel.selectedModel {
                        configRow("模型", model.displayName)
                        Divider()
                    }
                    if let auth = viewModel.selectedAuthChoice {
                        configRow("驗證方式", auth.label)
                        Divider()
                    }
                    if viewModel.enableFailover, let failover = provider.failoverModel {
                        configRow("備援模型", failover.displayName)
                        Divider()
                    }
                    configRow("設定檔", "~/.openclaw/openclaw.json")
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()
        }
        .padding(24)
    }

    private func configRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }

    // MARK: - Footer Navigation

    private var footerView: some View {
        HStack {
            // Back button
            if viewModel.currentStep != .selectProvider && viewModel.currentStep != .complete {
                Button("返回") {
                    viewModel.goBack()
                }
            }

            Spacer()

            // Primary action
            switch viewModel.currentStep {
            case .selectProvider:
                EmptyView()

            case .selectAuth:
                Button("繼續") {
                    viewModel.proceedFromAuth()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.selectedAuthChoice == nil)

            case .enterSecret:
                if let auth = viewModel.selectedAuthChoice,
                   auth.method == .deviceCode || auth.method == .oauth {
                    Button(viewModel.cliSucceeded ? "授權成功，繼續" : "跳過，稍後設定") {
                        viewModel.currentStep = .selectModel
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.oauthRunning)
                } else {
                    Button("驗證") {
                        viewModel.proceedFromSecret()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.secretInput.isEmpty)
                }

            case .selectModel:
                Button("完成設定") {
                    Task { await viewModel.validateAndSave() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.selectedModel == nil)

            case .validating:
                EmptyView()

            case .complete:
                Button("繼續") {
                    if let p = viewModel.selectedProvider,
                       let m = viewModel.selectedModel {
                        var meta = [
                            "provider": p.rawValue,
                            "model": m.id,
                            "auth": viewModel.selectedAuthChoice?.id ?? "unknown",
                            "failover": viewModel.enableFailover ? "on" : "off"
                        ]
                        if viewModel.enableFailover, let f = p.failoverModel {
                            meta["failover_model"] = f.id
                        }
                        appState.trackEvent("llm_setup_complete", module: "llm", meta: meta)
                    }
                    onComplete?()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

// MARK: - ViewModel

@MainActor
class LLMSetupViewModel: ObservableObject {
    enum Step {
        case selectProvider
        case selectAuth
        case enterSecret
        case selectModel
        case validating
        case complete
    }

    @Published var currentStep: Step = .selectProvider
    @Published var selectedProvider: LLMProvider?
    @Published var selectedAuthChoice: AuthChoice?
    @Published var selectedModel: ModelOption?
    @Published var secretInput: String = ""
    @Published var showKey: Bool = false
    @Published var validationError: String?
    @Published var enableFailover: Bool = true

    func selectProvider(_ provider: LLMProvider) {
        selectedProvider = provider
        selectedAuthChoice = provider.defaultAuthChoice
        selectedModel = provider.defaultModel
        secretInput = ""
        validationError = nil
        enableFailover = provider.failoverModel != nil

        // Check if there's existing LLM config
        checkExistingLLMConfig()

        // If only one auth choice, skip auth selection
        if provider.authChoices.count == 1 {
            proceedFromAuth()
        } else {
            currentStep = .selectAuth
        }
    }

    /// Detect existing LLM config in ~/.openclaw/openclaw.json
    private func checkExistingLLMConfig() {
        let configManager = ConfigManager.shared
        configManager.loadConfig()
        if let provider = configManager.llmProviderName,
           let model = configManager.llmModelDisplay,
           !provider.isEmpty {
            existingLLMDetected = true
            existingLLMSummary = "\(provider.capitalized) \(model)"
        } else {
            existingLLMDetected = false
            existingLLMSummary = ""
        }
    }

    @Published var oauthStatus: String = ""
    @Published var oauthRunning: Bool = false
    @Published var cliOutputLines: [String] = []
    @Published var cliExitCode: Int32? = nil
    @Published var cliSucceeded: Bool = false
    @Published var existingLLMDetected: Bool = false
    @Published var existingLLMSummary: String = ""

    func proceedFromAuth() {
        guard let authChoice = selectedAuthChoice else { return }

        switch authChoice.method {
        case .apiKey, .setupToken:
            currentStep = .enterSecret
        case .deviceCode, .oauth:
            // Run OAuth inline inside the app
            currentStep = .enterSecret
            runOAuthInline()
        case .none:
            currentStep = .selectModel
        }
    }

    func proceedFromSecret() {
        guard let provider = selectedProvider,
              let authChoice = selectedAuthChoice else { return }

        // Validate input
        if !provider.validateInput(secretInput, authChoice: authChoice) {
            if authChoice.method == .setupToken {
                validationError = "Token 格式無效，請確認已正確複製"
            } else if !provider.keyPrefix.isEmpty {
                validationError = "金鑰格式無效，應以 \(provider.keyPrefix) 開頭"
            } else {
                validationError = "金鑰格式無效"
            }
            return
        }

        validationError = nil
        currentStep = .selectModel
    }

    func goBack() {
        guard let provider = selectedProvider else {
            currentStep = .selectProvider
            return
        }

        switch currentStep {
        case .selectAuth:
            currentStep = .selectProvider
        case .enterSecret:
            if provider.authChoices.count > 1 {
                currentStep = .selectAuth
            } else {
                currentStep = .selectProvider
            }
        case .selectModel:
            if let authChoice = selectedAuthChoice,
               authChoice.method == .apiKey || authChoice.method == .setupToken {
                currentStep = .enterSecret
            } else if provider.authChoices.count > 1 {
                currentStep = .selectAuth
            } else {
                currentStep = .selectProvider
            }
        default:
            currentStep = .selectProvider
        }
    }

    func validateAndSave() async {
        guard let provider = selectedProvider,
              let model = selectedModel else { return }

        validationError = nil
        currentStep = .validating

        // Simulate API validation
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            try saveToConfig(provider: provider, model: model)
            currentStep = .complete
        } catch {
            validationError = error.localizedDescription
            currentStep = .selectModel
        }
    }

    /// Build the full openclaw onboard command string for OAuth
    func oauthCommand() -> String {
        guard let provider = selectedProvider,
              let authChoice = selectedAuthChoice else { return "" }
        let authChoiceValue = provider.onboardAuthChoiceValue(for: authChoice) ?? authChoice.id
        return "openclaw onboard --auth-choice \(authChoiceValue)"
    }

    /// Run OAuth inline — streams CLI output into the app
    func runOAuthInline() {
        guard !oauthRunning else { return }
        oauthRunning = true
        cliOutputLines = []
        cliExitCode = nil
        cliSucceeded = false
        oauthStatus = "正在執行..."

        let cmd = oauthCommand()

        Task { @MainActor in
            let result = await ShellRunner.runWithStreaming(cmd, onOutput: { [weak self] text in
                self?.appendCLIOutput(text)
            }, onError: { [weak self] text in
                self?.appendCLIOutput(text)
            })

            cliExitCode = result.exitCode
            oauthRunning = false

            if result.success {
                cliSucceeded = true
                oauthStatus = "授權完成"
                cliOutputLines.append("")
                cliOutputLines.append("[完成] 授權設定成功")
            } else {
                oauthStatus = "執行失敗（exit code \(result.exitCode)）"
                cliOutputLines.append("")
                cliOutputLines.append("[錯誤] 指令結束，exit code: \(result.exitCode)")
            }
        }
    }

    private func appendCLIOutput(_ text: String) {
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            if !line.isEmpty {
                cliOutputLines.append(line)
            }
        }
    }

    /// Parsed and cleaned CLI output lines for display
    struct ParsedLine {
        let text: String
        let color: Color
    }

    var parsedCLILines: [ParsedLine] {
        cliOutputLines.compactMap { raw in
            let cleaned = Self.stripAnsi(raw)
            // Skip pure box-drawing decoration lines
            let stripped = cleaned.trimmingCharacters(in: .whitespaces)
            if stripped.isEmpty { return nil }
            // Skip lines that are only box chars (─│┌┐└┘├┤┬┴┼╭╮╰╯)
            let boxChars = CharacterSet(charactersIn: "─│┌┐└┘├┤┬┴┼╭╮╰╯◇◆○●▸▹|+- \t")
            if stripped.unicodeScalars.allSatisfy({ boxChars.contains($0) }) && stripped.count > 2 {
                return nil
            }
            let color = Self.lineColor(cleaned)
            return ParsedLine(text: cleaned, color: color)
        }
    }

    /// Extract a human-readable error summary from CLI output
    var cliErrorSummary: String {
        let lines = cliOutputLines.map { Self.stripAnsi($0) }
        // Look for "Config invalid", "Error:", "Problem:" etc.
        if let configLine = lines.first(where: { $0.contains("Config invalid") || $0.contains("Invalid config") }) {
            return configLine.trimmingCharacters(in: .whitespaces)
        }
        if let errorLine = lines.first(where: { $0.lowercased().contains("error") && !$0.contains("[錯誤]") }) {
            return errorLine.trimmingCharacters(in: .whitespaces)
        }
        if let problemLine = lines.first(where: { $0.contains("Problem:") }) {
            return problemLine.trimmingCharacters(in: .whitespaces)
        }
        return "指令執行失敗，請查看下方輸出或在終端機手動執行"
    }

    /// Strip ANSI escape sequences
    private static func stripAnsi(_ text: String) -> String {
        text.replacingOccurrences(
            of: "\\x1b\\[[0-9;]*[a-zA-Z]|\\e\\[[0-9;]*[a-zA-Z]|\\u001B\\[[0-9;]*[a-zA-Z]",
            with: "",
            options: .regularExpression
        )
    }

    /// Color for a cleaned CLI line
    private static func lineColor(_ line: String) -> Color {
        let lower = line.lowercased()
        if line.hasPrefix("[完成]") || lower.contains("success") || lower.contains("configured") { return .green }
        if line.hasPrefix("[錯誤]") || lower.contains("error") || lower.contains("invalid") { return Color(red: 1.0, green: 0.4, blue: 0.4) }
        if lower.contains("warning") { return .orange }
        if lower.contains("http://") || lower.contains("https://") { return .cyan }
        if lower.contains("doctor") || lower.contains("config") { return .yellow.opacity(0.8) }
        return .white.opacity(0.75)
    }

    /// Save config via `openclaw onboard --non-interactive` for API key / token,
    /// or via ConfigManager as fallback
    private func saveToConfig(provider: LLMProvider, model: ModelOption) throws {
        let authChoice = selectedAuthChoice

        // For API key / token providers, try openclaw onboard CLI first
        if let auth = authChoice,
           (auth.method == .apiKey || auth.method == .setupToken),
           !secretInput.isEmpty {
            let args = provider.onboardArgs(authChoice: auth, secret: secretInput, modelId: model.id)
            runOpenClawOnboard(args)
        }

        // Also save to local config for app display
        let configManager = ConfigManager.shared
        try configManager.setLLMConfig(
            provider: provider.rawValue,
            model: model.id,
            displayModel: model.displayName,
            apiKey: (authChoice?.method == .apiKey || authChoice?.method == .setupToken) ? secretInput : nil,
            configKey: authChoice?.method == .apiKey ? provider.configKey : nil
        )
    }

    /// Run `openclaw onboard` with given args in background
    private func runOpenClawOnboard(_ args: [String]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            task.environment = ProcessInfo.processInfo.environment
            task.environment?["PATH"] = "\(home)/.npm-global/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

            // Find openclaw binary
            let candidates = [
                "\(home)/.npm-global/bin/openclaw",
                "/opt/homebrew/bin/openclaw",
                "/usr/local/bin/openclaw"
            ]
            guard let bin = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else {
                return
            }

            task.executableURL = URL(fileURLWithPath: bin)
            task.arguments = args
            task.standardOutput = FileHandle.nullDevice
            task.standardError = FileHandle.nullDevice

            try? task.run()
            task.waitUntilExit()
        }
    }
}
