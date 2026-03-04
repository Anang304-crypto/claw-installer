# ClawInstaller

> 社群驅動的 macOS 安裝精靈，讓 [OpenClaw](https://github.com/openclaw/openclaw) 設定從 30 分鐘 CLI 操作變成 3 分鐘圖形化體驗。

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue.svg)](https://www.apple.com/macos)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**非官方專案，與 OpenClaw 團隊無關。**

[English](README.en.md)

---

## 為什麼需要 ClawInstaller？

OpenClaw 擁有 257K+ stars，但安裝流程對新手極不友好。根據 [GitHub Issues](https://github.com/openclaw/openclaw/issues) 分析：

- **~35%** 新用戶問題 = Node.js 版本錯誤、缺少原生套件（Sharp、CMake）
- **~25%** = 設定檔困惑（JSON 語法、頻道設定）
- **~15%** = 「裝好了但跑不起來」（daemon、port 衝突）

ClawInstaller 自動化最痛苦的前 5 分鐘 — 大多數人放棄的那個階段。

## 功能

| 模組 | 狀態 | 說明 |
|------|------|------|
| **環境檢測** | ✅ 完成 | 偵測 Node.js ≥22、套件管理器、架構、磁碟空間。一鍵修復。 |
| **安裝精靈** | 🔧 開發中 | 一鍵安裝，支援 npm/pnpm/bun，即時進度顯示 |
| **頻道設定** | ✅ 完成 | Telegram、Discord、WhatsApp 引導式設定 |
| **AI 供應商** | ✅ 完成 | 支援 Anthropic、Google AI、Ollama 一鍵設定 |
| **系統監控** | 📋 計畫中 | Gateway 狀態、daemon 啟停、日誌檢視 |
| **安裝助手** | 📋 計畫中 | AI 驅動的安裝疑難排解（免費額度） |

## 快速開始

```bash
git clone https://github.com/clawinstaller/claw-installer.git
cd claw-installer
swift build
swift run ClawInstaller
```

**系統需求：** macOS 14+（Sonoma）、Xcode 15+ 或 Swift 6.0 工具鏈

## 安裝流程

```
1. 歡迎 ────> 輸入信箱，取得啟用碼
                        |
2. 環境檢測 ──> 偵測 Node.js、npm/pnpm/bun、架構
                  發現問題？一鍵自動修復
                        |
3. 安裝 ────> 選擇最佳套件管理器，執行安裝，驗證
                        |
4. AI 供應商 ─> 選擇 Anthropic / Google AI / Ollama
                        |
5. 頻道設定 ──> Telegram / Discord / WhatsApp 引導設定
                        |
6. 完成 ────> NPS 回饋 + 分享到 Threads + 系統監控
```

## 錯誤處理

ClawInstaller 針對常見失敗情形提供智慧修復建議：

| 錯誤 | 修復方式 |
|------|---------|
| Node.js 未安裝 | 一鍵自動安裝 via Homebrew |
| 原生模組編譯失敗 | 一鍵安裝 Xcode CLI Tools |
| 網路連線逾時 | 重新嘗試 / 切換鏡像源 |

## 定價

| 方案 | 內容 | 費用 |
|------|------|------|
| **免費** | 環境檢測 + 安裝 + 頻道設定 + 監控 | $0 |
| **AI 助手** | AI 驅動的安裝疑難排解 | 免費額度（我們請客） |

## 社群

- **Threads**: [@clawinstaller](https://www.threads.net/@clawinstaller) — 追蹤獲取更新
- **Telegram**: 加入繁中使用者群組
- **Discord**: 開發者社群

安裝完成後掃描 QR Code 即可分享安裝體驗到 Threads！

## MCP 整合

內建 TypeScript MCP 伺服器，用於追蹤 OpenClaw GitHub Issues：

```bash
cd mcp && npm install && npm run build
```

4 個工具：`issues_search`、`issues_analyze`、`issues_read`、`issues_report`

用於數據驅動的功能優先級 — 分析哪些安裝痛點最該優先解決。

## 專案結構

```
claw-installer/
├── Package.swift                     # Swift Package Manager
├── Sources/ClawInstaller/
│   ├── ClawInstaller.swift           # App 入口 + NavigationSplitView
│   ├── AppState.swift                # 共享狀態
│   ├── ShellRunner.swift             # Shell 指令執行
│   ├── PreflightChecker.swift        # 模組 1：系統檢測
│   ├── PreflightView.swift           # 模組 1：UI
│   ├── Views/
│   │   ├── InstallWizardView.swift   # 模組 2：安裝精靈
│   │   ├── ChannelSetupView.swift    # 模組 3：頻道設定
│   │   ├── TelegramSetupView.swift
│   │   ├── DiscordSetupView.swift
│   │   └── WhatsAppSetupView.swift
│   ├── Models/
│   │   └── ConfigManager.swift       # ~/.openclaw/openclaw.json
│   └── Services/
│       ├── ClaudeService.swift       # AI 支援（模組 5）
│       └── KnowledgeBase.swift       # 文件 + Issue 上下文
├── mcp/                              # GitHub Issues Tracker MCP
│   └── src/
│       ├── index.ts                  # MCP 伺服器 + 4 工具
│       ├── gh-runner.ts              # gh CLI 橋接
│       ├── categorizer.ts            # Issue 分類器
│       └── cache.ts                  # JSONL 投訴資料庫
└── docs/community-posts/             # PMF 驗證草稿
```

## 開發路線

- [x] 模組 1：環境檢測
- [x] 模組 3：頻道設定（Telegram、Discord、WhatsApp）
- [x] 模組 6：AI 供應商設定（Anthropic、Google AI、Ollama）
- [x] MCP：GitHub Issues Tracker
- [x] UI 設計：全繁中安裝流程（8 畫面 + 3 錯誤情形 + 產品主頁）
- [ ] 模組 2：安裝精靈（開發中）
- [ ] 模組 4：系統監控
- [ ] 安裝助手：AI 疑難排解
- [ ] Threads QR Code 分享功能
- [ ] Homebrew Cask formula
- [ ] Demo GIF / 影片
- [ ] 痛點報告（Issue 數據分析）

## 貢獻

早期階段 — 歡迎各種貢獻：

1. **測試** — 在你的 Mac 上測試，回報問題
2. **分享痛點** — 告訴我們 OpenClaw 安裝時遇到什麼困難
3. **PR 歡迎** — 查看 [open issues](https://github.com/clawinstaller/claw-installer/issues)

## 授權

[MIT](LICENSE)

---

由 [@howardpen9](https://github.com/howardpen9) 搭配 OpenClaw agents（Friday、Shuri、Muse）共同打造。
