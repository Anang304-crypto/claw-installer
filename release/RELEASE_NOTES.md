# ClawInstaller v0.1.3-beta

> macOS 原生 OpenClaw 安裝精靈 — 內建 AI 助手

## v0.1.3 更新內容

### 新功能

- **一鍵修復** — 安裝失敗時直接顯示「一鍵修復」按鈕，不需要手動跑指令
- **AI 助手自動帶入上下文** — 點「問 AI 助手」自動傳送錯誤訊息 + 安裝 Log，不需手動描述問題
- **Sidebar 版本號** — 左側選單底部顯示目前 App 版本
- **驗證碼顯示完整信箱** — 不再遮罩 email 地址

### 修復與改善

- **介面全面中文化** — 安裝頁面所有文字改為繁體中文
- **視窗高度再次調整** — 確保所有內容不被裁切
- **App Icon 修復** — 去除圓角處白色像素，Dock 上顯示正常
- **pnpm 錯誤辨識** — 正確辨識 `ERR_PNPM_NO_GLOBAL_BIN_DIR`，一鍵修復

### 功能模組

| 模組 | 狀態 | 說明 |
|------|------|------|
| 環境檢測 | ✅ 完成 | 自動偵測 Node.js、系統架構、套件管理器，一鍵修復常見問題 |
| 安裝精靈 | ✅ 完成 | 一鍵安裝 OpenClaw，即時進度顯示、錯誤偵測、自動修復 |
| 頻道設定 | ✅ 完成 | Telegram、Discord、WhatsApp 逐步設定指引 |
| LLM 設定 | ✅ 完成 | 選擇 AI 供應商（Anthropic、Google、Ollama），自動驗證 API Key |
| AI 助手 | ✅ 完成 | 內建繁中 AI 助手，自動帶入系統狀態，即問即答 |
| 健康監控 | 🔜 預覽 | Gateway 狀態顯示，完整控制即將推出 |

### 亮點功能

- **智慧錯誤導引** — 遇到問題時，點「問 AI 助手」自動帶入完整系統資訊
- **全新 Mac 支援** — 即使是剛開箱的 Mac 也能引導安裝 Node.js
- **免設定 AI** — 內建 AI 助手開箱即用，不需要 API Key
- **動態 PATH 偵測** — 支援 nvm、fnm、volta、asdf、Homebrew（Apple Silicon + Intel）

## 安裝方式

### 直接下載

1. 下載下方的 `ClawInstaller-0.1.3-beta-macos.dmg`
2. 打開 DMG，將 ClawInstaller 拖入「應用程式」資料夾
3. 首次開啟：右鍵 → 打開（繞過 macOS 安全提示）
4. 如果看到「ClawInstaller 已損壞」，請在終端機執行：
   ```bash
   xattr -cr /Applications/ClawInstaller.app
   ```
   然後正常開啟即可。

> 💡 正式版將加入 Apple 公證簽名，屆時雙擊就能直接開啟。

## 系統需求

- macOS 14.0（Sonoma）或更新版本
- Apple Silicon 或 Intel Mac
- 約 100MB 磁碟空間

## 快速開始

1. **環境檢測** — 確認你的系統已就緒
2. **安裝 OpenClaw** — 一鍵完成安裝
3. **設定頻道** — 連接 Telegram、Discord 或 WhatsApp
4. **設定 LLM** — 選擇你的 AI 供應商
5. **問 AI** — 遇到問題隨時開啟 AI 助手

## 已知問題

- 目前尚未加入 Apple 公證簽名，首次開啟需手動允許（詳見上方安裝說明）
- 健康監控為預覽版，完整功能將於下個版本推出
- WhatsApp QR 掃描需要 Gateway 先啟動

## 回饋與社群

發現 Bug？[開 Issue 回報](https://github.com/clawinstaller/claw-installer/issues/new)

Telegram 社群：[ClawInstaller Community](https://t.me/clawinstaller)
Threads：[@0xhoward_peng](https://www.threads.com/@0xhoward_peng)
