# Changelog

All notable changes to ClawInstaller will be documented in this file.

## [0.1.0-beta] - 2026-03-05

### Initial Beta Release

First public beta of ClawInstaller — a community-driven macOS setup wizard for OpenClaw with built-in AI assistant.

### Features

#### Module 1: Preflight Check
- Detects Node.js version (requires >= 22)
- Identifies available package managers (npm, pnpm, bun, yarn)
- Checks system architecture (Apple Silicon / Intel)
- Verifies existing OpenClaw installation
- Shows disk space availability
- One-click fix actions for common issues
- Fresh Mac detection with guided Node.js install

#### Module 2: Install Wizard
- One-click OpenClaw installation
- Automatic package manager detection (prefers pnpm > bun > npm)
- Live terminal output streaming with color parsing
- 5-stage progress tracking (checking > downloading > installing > configuring > verifying)
- Error detection: EACCES, network, gyp with auto-fix suggestions
- Smart error guidance: "Ask AI Assistant" button carries error context

#### Module 3: Channel Setup
- Guided Telegram bot setup with BotFather walkthrough
- Discord bot configuration with Developer Portal guide
- WhatsApp Web linking instructions
- Token validation before saving
- Auto-writes configuration to `~/.openclaw/openclaw.json`

#### Module 3b: LLM Setup
- Provider selection: Anthropic (recommended), Google AI (free), Ollama (local)
- API key format validation with live feedback
- Ollama auto-detection via localhost API
- Step-by-step setup guides with direct links

#### Module 5: AI Support
- Full chat interface with message bubbles
- Context-aware responses (Node version, arch, errors, channels)
- Traditional Chinese (繁體中文) responses
- Pre-tuned for OpenClaw installation troubleshooting
- Free to use (no API key required)

#### Smart Error Guidance
- Preflight failures show "Ask AI Assistant" button
- Install failures show "Ask AI Assistant" button
- AI receives full system context automatically

#### Infrastructure
- Anonymous telemetry (opt-out available)
- Backend API for AI chat and funnel analytics
- Dynamic PATH detection: nvm, fnm, volta, asdf, Homebrew

### Technical

- Swift 6.0 + SwiftUI
- macOS 14.0 (Sonoma) minimum
- Native Apple Silicon support
- Zero external dependencies
- Dark mode compatible

### Contributors

- @howardpen9 + OpenClaw agents (Friday, Shuri, Muse)

---

[0.1.0-beta]: https://github.com/clawinstaller/claw-installer/releases/tag/v0.1.0-beta
