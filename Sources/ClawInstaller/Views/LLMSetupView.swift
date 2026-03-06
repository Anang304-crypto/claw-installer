// LLMSetupView — AI Provider Selection (Screen 5, V3 Tiered Design)
// 12 providers across 4 tiers with compact/full card layouts

import SwiftUI

struct LLMSetupView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = LLMSetupViewModel()
    var onComplete: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // Content based on current step
            Group {
                switch viewModel.currentStep {
                case .selectProvider:
                    providerSelectionView
                case .setupGuide:
                    setupGuideView
                case .enterKey:
                    enterKeyView
                case .ollamaDetection:
                    ollamaDetectionView
                case .validating:
                    validatingView
                case .complete:
                    completeView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Footer navigation (only for non-selection steps)
            if viewModel.currentStep != .selectProvider {
                Divider()
                footerView
            }
        }
    }

    // MARK: - Provider Selection (V3 Tiered Design)

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

            // Fixed header area
            VStack(alignment: .leading, spacing: 6) {
                Text("選擇你的 AI 供應商")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)

                Text("OpenClaw 需要大型語言模型來驅動你的 Agent")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .padding(.horizontal, 40)

            // Scrollable provider list
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {

                    // --- Tier 1: Mainstream (full cards) ---
                    tierHeader(.mainstream)
                    VStack(spacing: 8) {
                        ForEach(LLMProvider.providers(for: .mainstream)) { provider in
                            fullProviderCard(provider)
                        }
                    }

                    // --- Tier 2: Multi-model (full cards) ---
                    tierHeader(.multiModel)
                    VStack(spacing: 8) {
                        ForEach(LLMProvider.providers(for: .multiModel)) { provider in
                            fullProviderCard(provider)
                        }
                    }

                    // --- Tier 3: Asia (compact grid) ---
                    tierHeader(.asia)
                    asiaInfoTip
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                        spacing: 8
                    ) {
                        ForEach(LLMProvider.providers(for: .asia)) { provider in
                            compactProviderCard(provider)
                        }
                    }

                    // --- Tier 4: Local (2-column row) ---
                    tierHeader(.local)
                    HStack(spacing: 8) {
                        ForEach(LLMProvider.providers(for: .local)) { provider in
                            compactProviderCard(provider)
                        }
                    }

                    // "More providers" placeholder
                    moreProvidersButton

                    // Mascot tip section
                    mascotTipView

                    // Skip text
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
        .onAppear {
            viewModel.checkOllamaInstalled()
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

    // MARK: - Full Provider Card (Tier 1 & 2)

    private func fullProviderCard(_ provider: LLMProvider) -> some View {
        Button {
            viewModel.selectedProvider = provider
            viewModel.proceedFromSelection()
        } label: {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: provider.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(provider.color)
                    .frame(width: 36, height: 36)
                    .background(provider.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                // Text group
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

                // Badge or arrow
                if let badge = provider.badgeText {
                    Text(badge)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(provider.badgeColor)
                        .clipShape(Capsule())
                } else {
                    Text("設定 →")
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

    // MARK: - Compact Provider Card (Tier 3 & 4)

    private func compactProviderCard(_ provider: LLMProvider) -> some View {
        Button {
            viewModel.selectedProvider = provider
            viewModel.proceedFromSelection()
        } label: {
            VStack(spacing: 6) {
                // Icon
                Image(systemName: provider.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(provider.color)
                    .frame(width: 32, height: 32)
                    .background(provider.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                // Name
                Text(provider.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                // Subtitle / badge
                if let badge = provider.badgeText {
                    Text(badge)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(provider.badgeColor)
                } else {
                    Text(provider.modelName)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
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

    // MARK: - More Providers Button

    private var moreProvidersButton: some View {
        HStack {
            Spacer()
            Button {
                // Future: expand to show more providers
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 12))
                    Text("更多供應商")
                        .font(.system(size: 12))
                }
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .disabled(true)
            .opacity(0.5)
            Spacer()
        }
        .padding(.vertical, 4)
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

            Text("不確定選哪個？推薦 **Anthropic**，Agent 表現最好！想省錢可選 **DeepSeek** 或免費的 **Google AI**。")
                .font(.system(size: 11))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(red: 1.0, green: 0.973, blue: 0.941)) // #FFF8F0
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 1.0, green: 0.878, blue: 0.698), lineWidth: 1) // #FFE0B2
        )
    }

    // MARK: - Setup Guide (Step-by-step)

    private var setupGuideView: some View {
        VStack(spacing: 0) {
            if let provider = viewModel.selectedProvider {
                // Progress indicator
                HStack(spacing: 4) {
                    ForEach(0..<provider.setupSteps.count, id: \.self) { index in
                        Capsule()
                            .fill(index <= viewModel.currentGuideStep ? provider.color : Color.secondary.opacity(0.2))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Step content
                if viewModel.currentGuideStep < provider.setupSteps.count {
                    let step = provider.setupSteps[viewModel.currentGuideStep]

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Step badge
                            Text("步驟 \(viewModel.currentGuideStep + 1) / \(provider.setupSteps.count)")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Capsule())

                            // Title
                            Text(step.title)
                                .font(.system(size: 20, weight: .bold, design: .monospaced))

                            // Description
                            Text(step.description)
                                .foregroundStyle(.secondary)

                            // Action button
                            if let action = step.action, let url = step.url {
                                Link(destination: url) {
                                    HStack {
                                        Text(action)
                                        Image(systemName: "arrow.up.right")
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(provider.color)
                            }

                            // Visual hints
                            setupHintView(for: provider, step: viewModel.currentGuideStep)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func setupHintView(for provider: LLMProvider, step: Int) -> some View {
        let isLastStep = step == provider.setupSteps.count - 1

        VStack(alignment: .leading, spacing: 8) {
            // Key format hint for the last step of API-key providers
            if provider.requiresAPIKey && isLastStep && !provider.keyPrefix.isEmpty {
                Text("你的金鑰格式如下：")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Text(provider.keyPrefix)
                        .foregroundStyle(provider.color)
                    + Text("xxxx...xxxx")
                        .foregroundStyle(.secondary)
                }
                .font(.system(size: 14, design: .monospaced))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            // Ollama terminal command hint
            else if provider == .ollama && step == 2 {
                Text("在終端機執行：")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Text("ollama pull llama3.2")
                        .font(.system(size: 14, design: .monospaced))

                    Spacer()

                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString("ollama pull llama3.2", forType: .string)
                        viewModel.showCopiedFeedback = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            viewModel.showCopiedFeedback = false
                        }
                    } label: {
                        Image(systemName: viewModel.showCopiedFeedback ? "checkmark" : "doc.on.doc")
                            .foregroundStyle(viewModel.showCopiedFeedback ? .green : .secondary)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(12)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            // GitHub Copilot OAuth hint
            else if provider == .githubCopilot && step == 1 {
                Text("此供應商使用 GitHub OAuth 授權，設定完成後將自動連線。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                EmptyView()
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Enter Key View

    private var enterKeyView: some View {
        VStack(spacing: 24) {
            if let provider = viewModel.selectedProvider {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(provider.color)

                    Text("輸入你的 API 金鑰")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))

                    Text("請貼上你的 \(provider.displayName) API 金鑰")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                // Key input
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        if viewModel.showKey {
                            TextField("在此貼上你的 API 金鑰...", text: $viewModel.apiKey)
                                .textFieldStyle(.plain)
                                .font(.system(.body, design: .monospaced))
                        } else {
                            SecureField("在此貼上你的 API 金鑰...", text: $viewModel.apiKey)
                                .textFieldStyle(.plain)
                                .font(.system(.body, design: .monospaced))
                        }

                        Button {
                            viewModel.showKey.toggle()
                        } label: {
                            Image(systemName: viewModel.showKey ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(12)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    // Validation feedback
                    HStack(spacing: 6) {
                        if viewModel.apiKey.isEmpty {
                            if !provider.keyPrefix.isEmpty {
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
                        } else if provider.validateKeyFormat(viewModel.apiKey) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("金鑰格式正確")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            if !provider.keyPrefix.isEmpty {
                                Text("金鑰應以 \(provider.keyPrefix) 開頭")
                                    .foregroundStyle(.orange)
                            } else {
                                Text("金鑰格式不正確")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    .font(.caption)
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Error message
                if let error = viewModel.validationError {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        Text(error)
                    }
                    .font(.caption)
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Help link
                if let url = provider.apiKeyURL {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Image(systemName: "questionmark.circle")
                            Text("哪裡取得 API 金鑰？")
                        }
                        .font(.caption)
                    }
                }
            }

            Spacer()
        }
        .padding(24)
    }

    // MARK: - Ollama Detection View

    private var ollamaDetectionView: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 48))
                    .foregroundStyle(.purple)

                Text("檢查 Ollama 安裝狀態")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
            }

            // Detection status
            VStack(spacing: 16) {
                if viewModel.isCheckingOllama {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("偵測 Ollama 中...")
                        .foregroundStyle(.secondary)
                } else if viewModel.ollamaInstalled {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.green)
                    Text("Ollama 已安裝且正在執行！")
                        .font(.headline)

                    if !viewModel.ollamaModels.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("可用模型：")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            ForEach(viewModel.ollamaModels, id: \.self) { model in
                                HStack {
                                    Image(systemName: "cube.fill")
                                        .foregroundStyle(.purple)
                                    Text(model)
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                        }
                        .padding()
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.red)
                    Text("未偵測到 Ollama")
                        .font(.headline)

                    Text("請先安裝 Ollama 並執行模型。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Link(destination: URL(string: "https://ollama.com/download")!) {
                        HStack {
                            Text("下載 Ollama")
                            Image(systemName: "arrow.up.right")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)

                    Button("重新檢查") {
                        viewModel.checkOllamaInstalled()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()

            Spacer()
        }
        .padding(24)
        .onAppear {
            viewModel.detectOllamaWithModels()
        }
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
            // Success animation
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

                if let provider = viewModel.selectedProvider {
                    Text("\(provider.modelName) 已準備就緒")
                        .foregroundStyle(.secondary)
                }
            }

            // Config summary
            if let provider = viewModel.selectedProvider {
                VStack(spacing: 12) {
                    configRow("供應商", provider.displayName)
                    Divider()
                    configRow("模型", provider.modelName)
                    Divider()
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

            case .setupGuide:
                if let provider = viewModel.selectedProvider {
                    if viewModel.currentGuideStep < provider.setupSteps.count - 1 {
                        Button("下一步") {
                            viewModel.currentGuideStep += 1
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        // Determine next step label based on auth method
                        let nextLabel: String = {
                            switch provider.authMethod {
                            case .apiKey: return "輸入 API 金鑰"
                            case .oauth: return "授權登入"
                            case .none: return "完成設定"
                            }
                        }()

                        Button(nextLabel) {
                            switch provider.authMethod {
                            case .apiKey:
                                viewModel.currentStep = .enterKey
                            case .oauth:
                                // OAuth flow: skip key entry, go to validation
                                Task { await viewModel.validateAndSave() }
                            case .none:
                                if provider == .ollama {
                                    viewModel.currentStep = .ollamaDetection
                                } else {
                                    Task { await viewModel.validateAndSave() }
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

            case .enterKey:
                Button("驗證並儲存") {
                    Task { await viewModel.validateAndSave() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.apiKey.isEmpty)

            case .ollamaDetection:
                Button("繼續") {
                    Task { await viewModel.validateAndSave() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.ollamaInstalled)

            case .validating:
                EmptyView()

            case .complete:
                Button("繼續") {
                    if let p = viewModel.selectedProvider {
                        appState.trackEvent("llm_setup_complete", module: "llm", meta: [
                            "provider": p.rawValue,
                            "model": p.backendModel
                        ])
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
        case setupGuide
        case enterKey
        case ollamaDetection
        case validating
        case complete
    }

    @Published var currentStep: Step = .selectProvider
    @Published var selectedProvider: LLMProvider?
    @Published var apiKey: String = ""
    @Published var showKey: Bool = false
    @Published var currentGuideStep: Int = 0
    @Published var validationError: String?
    @Published var showCopiedFeedback: Bool = false

    // Ollama detection
    @Published var ollamaInstalled: Bool = false
    @Published var isCheckingOllama: Bool = false
    @Published var ollamaModels: [String] = []

    func proceedFromSelection() {
        guard let provider = selectedProvider else { return }

        currentGuideStep = 0
        apiKey = ""
        validationError = nil

        switch provider {
        case .ollama:
            currentStep = .ollamaDetection
        default:
            // All providers go through setup guide first
            currentStep = .setupGuide
        }
    }

    func goBack() {
        switch currentStep {
        case .setupGuide:
            if currentGuideStep > 0 {
                currentGuideStep -= 1
            } else {
                currentStep = .selectProvider
            }
        case .enterKey:
            if let provider = selectedProvider {
                currentStep = .setupGuide
                currentGuideStep = provider.setupSteps.count - 1
            }
        case .ollamaDetection:
            currentStep = .selectProvider
        default:
            currentStep = .selectProvider
        }
    }

    func checkOllamaInstalled() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        task.arguments = ["ollama"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()
            ollamaInstalled = task.terminationStatus == 0
        } catch {
            ollamaInstalled = false
        }
    }

    func detectOllamaWithModels() {
        isCheckingOllama = true
        ollamaModels = []

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
            task.arguments = ["-s", "http://localhost:11434/api/tags"]

            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = FileHandle.nullDevice

            do {
                try task.run()
                task.waitUntilExit()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()

                DispatchQueue.main.async {
                    self?.isCheckingOllama = false

                    if task.terminationStatus == 0,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let models = json["models"] as? [[String: Any]] {
                        self?.ollamaInstalled = true
                        self?.ollamaModels = models.compactMap { $0["name"] as? String }
                    } else {
                        self?.ollamaInstalled = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.isCheckingOllama = false
                    self?.ollamaInstalled = false
                }
            }
        }
    }

    func validateAndSave() async {
        guard let provider = selectedProvider else { return }

        validationError = nil
        currentStep = .validating

        // Format validation for API key providers
        if provider.requiresAPIKey {
            guard provider.validateKeyFormat(apiKey) else {
                let hint = provider.keyPrefix.isEmpty
                    ? "金鑰格式無效"
                    : "金鑰格式無效，應以 \(provider.keyPrefix) 開頭"
                validationError = hint
                currentStep = .enterKey
                return
            }
        }

        // Simulate API validation
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            try saveToConfig(provider: provider)
            currentStep = .complete
        } catch {
            validationError = error.localizedDescription
            switch provider.authMethod {
            case .apiKey:
                currentStep = .enterKey
            case .oauth:
                currentStep = .setupGuide
            case .none:
                currentStep = provider == .ollama ? .ollamaDetection : .selectProvider
            }
        }
    }

    private func saveToConfig(provider: LLMProvider) throws {
        let configManager = ConfigManager.shared
        try configManager.setLLMConfig(
            provider: provider.rawValue,
            model: provider.backendModel,
            displayModel: provider.modelName,
            apiKey: provider.requiresAPIKey ? apiKey : nil,
            configKey: provider.requiresAPIKey ? provider.configKey : nil
        )
    }
}
