import Foundation

/// Module 1: Detect environment prerequisites
@MainActor
final class PreflightChecker: ObservableObject {
    @Published var checks: [PreflightCheck] = []
    @Published var isRunning = false

    func runAll() async {
        isRunning = true
        checks = [
            PreflightCheck(name: "Node.js", description: "Version ≥ 22 required", status: .checking),
            PreflightCheck(name: "Package Manager", description: "npm, pnpm, or bun", status: .checking),
            PreflightCheck(name: "Architecture", description: "Apple Silicon or Intel", status: .checking),
            PreflightCheck(name: "OpenClaw", description: "Existing installation", status: .checking),
            PreflightCheck(name: "OpenClaw Config", description: "~/.openclaw/openclaw.json", status: .checking),
        ]

        checks[0] = await checkNode()
        checks[1] = await checkPackageManager()
        checks[2] = await checkArch()
        checks[3] = await checkExistingOpenClaw()
        checks[4] = await checkOpenClawConfig()

        isRunning = false
    }

    private func checkNode() async -> PreflightCheck {
        let result = await ShellRunner.run("node --version 2>/dev/null")
        if !result.success || result.stdout.isEmpty {
            return PreflightCheck(
                name: "Node.js",
                description: "Version ≥ 22 required",
                status: .fail,
                detail: "Node.js not found",
                fixAction: "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash && nvm install 22"
            )
        }
        // Parse version: "v22.1.0" → 22
        let version = result.stdout.replacingOccurrences(of: "v", with: "")
        let major = Int(version.split(separator: ".").first ?? "0") ?? 0
        if major < 22 {
            return PreflightCheck(
                name: "Node.js",
                description: "Version ≥ 22 required",
                status: .warn,
                detail: "Found v\(version), need ≥ 22",
                fixAction: "nvm install 22 && nvm use 22"
            )
        }
        return PreflightCheck(
            name: "Node.js",
            description: "Version ≥ 22 required",
            status: .pass,
            detail: "v\(version)"
        )
    }

    private func checkPackageManager() async -> PreflightCheck {
        var found: [String] = []
        for pm in ["npm", "pnpm", "bun"] {
            let r = await ShellRunner.run("which \(pm) 2>/dev/null")
            if r.success && !r.stdout.isEmpty { found.append(pm) }
        }
        if found.isEmpty {
            return PreflightCheck(
                name: "Package Manager",
                description: "npm, pnpm, or bun",
                status: .fail,
                detail: "None found",
                fixAction: "npm comes with Node.js — install Node first"
            )
        }
        return PreflightCheck(
            name: "Package Manager",
            description: "npm, pnpm, or bun",
            status: .pass,
            detail: found.joined(separator: ", ")
        )
    }

    private func checkArch() async -> PreflightCheck {
        let result = await ShellRunner.run("uname -m")
        let arch = result.stdout
        return PreflightCheck(
            name: "Architecture",
            description: "Apple Silicon or Intel",
            status: .pass,
            detail: arch == "arm64" ? "Apple Silicon (arm64)" : "Intel (x86_64)"
        )
    }

    private func checkExistingOpenClaw() async -> PreflightCheck {
        let result = await ShellRunner.run("which openclaw 2>/dev/null")
        if result.success && !result.stdout.isEmpty {
            let versionResult = await ShellRunner.run("openclaw --version 2>/dev/null")
            return PreflightCheck(
                name: "OpenClaw",
                description: "Existing installation",
                status: .pass,
                detail: "Found: \(versionResult.stdout.isEmpty ? result.stdout : versionResult.stdout)"
            )
        }
        return PreflightCheck(
            name: "OpenClaw",
            description: "Existing installation",
            status: .warn,
            detail: "Not installed yet — will install in next step"
        )
    }

    private func checkOpenClawConfig() async -> PreflightCheck {
        let configPath = NSHomeDirectory() + "/.openclaw/openclaw.json"
        if FileManager.default.fileExists(atPath: configPath) {
            return PreflightCheck(
                name: "OpenClaw Config",
                description: "~/.openclaw/openclaw.json",
                status: .pass,
                detail: "Config file exists"
            )
        }
        return PreflightCheck(
            name: "OpenClaw Config",
            description: "~/.openclaw/openclaw.json",
            status: .warn,
            detail: "No config yet — will create during setup"
        )
    }
}
