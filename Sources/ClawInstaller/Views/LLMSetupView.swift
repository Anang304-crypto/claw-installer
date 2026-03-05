// LLMSetupView — AI Provider Selection (Screen 5)
// Three options: Anthropic (recommended), Google AI (free), Ollama (local)

import SwiftUI

struct LLMSetupView: View {
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
            
            Divider()
            
            // Footer navigation
            footerView
        }
    }
    
    // MARK: - Provider Selection (Main Screen)
    
    private var providerSelectionView: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "brain")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                
                Text("Choose Your AI Provider")
                    .font(.title2.bold())
                
                Text("Select which AI model will power your assistant")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 20)
            
            // Provider cards
            VStack(spacing: 12) {
                ForEach(LLMProvider.allCases) { provider in
                    ProviderOptionCard(
                        provider: provider,
                        isSelected: viewModel.selectedProvider == provider,
                        ollamaInstalled: provider == .ollama ? viewModel.ollamaInstalled : nil
                    ) {
                        viewModel.selectedProvider = provider
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.checkOllamaInstalled()
        }
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
                            Text("Step \(viewModel.currentGuideStep + 1) of \(provider.setupSteps.count)")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Capsule())
                            
                            // Title
                            Text(step.title)
                                .font(.title2.bold())
                            
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
        VStack(alignment: .leading, spacing: 8) {
            switch (provider, step) {
            case (.anthropic, 3), (.google, 2):
                // Key format hint
                Text("Your key will look like:")
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
                
            case (.ollama, 2):
                // Terminal command
                Text("Run in Terminal:")
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
                
            default:
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
                    
                    Text("Enter Your API Key")
                        .font(.title2.bold())
                    
                    Text("Paste your \(provider.displayName) API key below")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Key input
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        if viewModel.showKey {
                            TextField("Paste your API key here...", text: $viewModel.apiKey)
                                .textFieldStyle(.plain)
                                .font(.system(.body, design: .monospaced))
                        } else {
                            SecureField("Paste your API key here...", text: $viewModel.apiKey)
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
                            Image(systemName: "info.circle")
                                .foregroundStyle(.secondary)
                            Text("Starts with \(provider.keyPrefix)...")
                                .foregroundStyle(.secondary)
                        } else if provider.validateKeyFormat(viewModel.apiKey) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Key format looks correct")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("Key should start with \(provider.keyPrefix)")
                                .foregroundStyle(.orange)
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
                            Text("Where do I find my API key?")
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
                
                Text("Checking Ollama Installation")
                    .font(.title2.bold())
            }
            
            // Detection status
            VStack(spacing: 16) {
                if viewModel.isCheckingOllama {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Detecting Ollama...")
                        .foregroundStyle(.secondary)
                } else if viewModel.ollamaInstalled {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.green)
                    Text("Ollama is installed and running!")
                        .font(.headline)
                    
                    if !viewModel.ollamaModels.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Available models:")
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
                    Text("Ollama not detected")
                        .font(.headline)
                    
                    Text("Please install Ollama and run a model first.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Link(destination: URL(string: "https://ollama.com/download")!) {
                        HStack {
                            Text("Download Ollama")
                            Image(systemName: "arrow.up.right")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    
                    Button("Check Again") {
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
            
            Text("Validating...")
                .font(.headline)
            
            if let provider = viewModel.selectedProvider {
                Text("Testing connection to \(provider.displayName)")
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
                Text("AI Provider Configured!")
                    .font(.title2.bold())
                
                if let provider = viewModel.selectedProvider {
                    Text("\(provider.modelName) is ready to use")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Config summary
            if let provider = viewModel.selectedProvider {
                VStack(spacing: 12) {
                    configRow("Provider", provider.displayName)
                    Divider()
                    configRow("Model", provider.modelName)
                    Divider()
                    configRow("Config", "~/.openclaw/openclaw.json")
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
                Button("Back") {
                    viewModel.goBack()
                }
            }
            
            Spacer()
            
            // Primary action
            switch viewModel.currentStep {
            case .selectProvider:
                Button("Continue") {
                    viewModel.proceedFromSelection()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.selectedProvider == nil)
                
            case .setupGuide:
                if let provider = viewModel.selectedProvider {
                    if viewModel.currentGuideStep < provider.setupSteps.count - 1 {
                        Button("Next Step") {
                            viewModel.currentGuideStep += 1
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button(provider.requiresAPIKey ? "Enter API Key" : "Finish Setup") {
                            if provider.requiresAPIKey {
                                viewModel.currentStep = .enterKey
                            } else {
                                Task { await viewModel.validateAndSave() }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
            case .enterKey:
                Button("Validate & Save") {
                    Task { await viewModel.validateAndSave() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.apiKey.isEmpty)
                
            case .ollamaDetection:
                Button("Continue") {
                    Task { await viewModel.validateAndSave() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.ollamaInstalled)
                
            case .validating:
                EmptyView()
                
            case .complete:
                Button("Continue") {
                    onComplete?()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

// MARK: - Provider Option Card

struct ProviderOptionCard: View {
    let provider: LLMProvider
    let isSelected: Bool
    let ollamaInstalled: Bool?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(provider.color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: provider.iconName)
                        .font(.title2)
                        .foregroundStyle(provider.color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(provider.displayName)
                            .font(.headline)
                        
                        if let badge = provider.badge {
                            Text(badge)
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(provider.badgeColor)
                                .clipShape(Capsule())
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(provider.modelName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Text(provider.tagline)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Ollama installation status
                    if let installed = ollamaInstalled {
                        HStack(spacing: 4) {
                            Image(systemName: installed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(installed ? .green : .red)
                            Text(installed ? "Installed" : "Not detected")
                                .foregroundStyle(installed ? .green : .red)
                        }
                        .font(.caption)
                    }
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? provider.color : .secondary.opacity(0.3))
            }
            .padding(16)
            .background(isSelected ? provider.color.opacity(0.05) : Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? provider.color : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
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
        
        switch provider {
        case .ollama:
            currentStep = .ollamaDetection
        case .anthropic, .google:
            currentStep = .setupGuide
            currentGuideStep = 0
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
            // Check if ollama is running by querying the API
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
                validationError = "Invalid key format. Should start with \(provider.keyPrefix)"
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
            currentStep = provider.requiresAPIKey ? .enterKey : .ollamaDetection
        }
    }
    
    private func saveToConfig(provider: LLMProvider) throws {
        let configDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".openclaw")
        let configFile = configDir.appendingPathComponent("openclaw.json")
        
        // Ensure directory exists
        try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
        
        // Read existing config or create new
        var config: [String: Any] = [:]
        if let data = try? Data(contentsOf: configFile),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            config = existing
        }
        
        // Update LLM config
        var llm = config["llm"] as? [String: Any] ?? [:]
        llm["provider"] = provider.rawValue
        llm["model"] = provider.backendModel  // Use backend model identifier
        llm["displayModel"] = provider.modelName  // For UI display
        
        if provider.requiresAPIKey {
            llm[provider.configKey] = apiKey
        }
        
        config["llm"] = llm
        
        // Write back
        let data = try JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: configFile)
    }
}

