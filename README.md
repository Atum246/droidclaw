# 🤖 DroidClaw — The Ultimate AI Agent for Android

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&style=for-the-badge" />
  <img src="https://img.shields.io/badge/Android-5.0+-green?logo=android&style=for-the-badge" />
  <img src="https://img.shields.io/badge/AI_Providers-35+-purple?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Tools-90+-red?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Skills-110+-orange?style=for-the-badge" />
</p>

<p align="center">
  <b>OpenClaw in your pocket. Not a chat app — a fully autonomous AI agent that can do ANYTHING on your phone.</b>
</p>

---

## 📋 Table of Contents

- [What is DroidClaw?](#-what-is-droidclaw)
- [Features](#-features)
- [AI Providers (35+)](#-35-ai-providers)
- [Tools (80+)](#-80-tools)
- [Skills (110+)](#-110-skills)
- [Local Model Downloads](#-download-ai-models-to-your-phone)
- [Architecture](#-architecture)
- [Screenshots](#-ui-screens)
- [Build APK Guide](#-build-your-apk)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 What is DroidClaw?

**DroidClaw** is a full AI agent platform for Android — inspired by [OpenClaw](https://github.com/openclaw/openclaw). Unlike regular chat apps, DroidClaw is an **agent that ACTS**:

- 🔧 **Executes tools** — file ops, web search, code, phone control
- 📱 **Controls your phone** — calls, alarms, settings, apps, camera
- 🖥️ **Remotely controls devices** — SSH into laptops, send keystrokes
- 🧠 **Remembers everything** — persistent memory across sessions
- ⏰ **Automates tasks** — cron jobs, reminders, workflows
- 📥 **Downloads local AI models** — run AI directly on your phone
- 🎤 **Voice I/O** — speak to it, it speaks back
- 📁 **Manages files** — upload, download, share any file

---

## ✨ Features

### 🤖 AI Agent (Not Just Chat)
- **Agent loop**: Model → Tools → Model → Response
- **Multi-step reasoning**: Agent can iterate up to 10 times
- **Real-time task tracking**: See what the agent is doing live
- **Tool execution**: 80+ tools across 16 categories
- **Skill activation**: 110+ skills auto-trigger based on context

### 📱 Full Phone Control
- 📞 Make/answer/reject calls
- ⏰ Set/delete/modify alarms & timers
- 💬 Send/read SMS, WhatsApp, Telegram, email
- 📸 Take photos, record videos, scan QR codes
- 🔊 Control volume, brightness, WiFi, Bluetooth
- ✈️ Toggle airplane mode, hotspot, DND
- 📱 Open/close/install/uninstall apps
- 🔒 Lock screen, take screenshots, record screen
- 📍 GPS location, maps, geofencing
- 🎵 Play music, set ringtones, manage media

### 🖥️ Remote Device Control
- 🔗 Connect to laptops/PCs via SSH
- 🖥️ Run commands on remote devices
- 📁 Read/write/list files remotely
- 📸 Screenshot remote screens
- ⌨️ Send keystrokes to remote keyboard
- 🖱️ Control remote mouse
- 📋 Access remote clipboard

### 📁 File Management
- 📤 Upload files from device (any type)
- 📥 Download generated content as files
- 🖼️ Pick images from gallery or camera
- 🎥 Pick videos
- 📤 Share files to any app
- 📋 Copy files to clipboard

### 🎤 Voice Interface
- 🎙️ Speech-to-text input
- 🔊 Text-to-speech output
- 🗣️ Multiple voice options
- ⚡ Adjustable speed & pitch

### ⏰ Automation
- 🔄 Cron jobs (recurring tasks)
- ⏰ One-shot reminders
- 🤖 Workflow automation
- 🔀 IFTTT-style rules
- 📅 Calendar integration

---

## 🤖 35+ AI Providers

### Cloud Providers
| Provider | Models | Type |
|----------|--------|------|
| 🟢 **OpenAI** | GPT-4o, GPT-4o Mini, GPT-4 Turbo, o1, o1-mini, o3-mini, Search | Cloud |
| 🟣 **Anthropic** | Claude Sonnet 4, Claude 3.5 Sonnet/Haiku, Claude 3 Opus | Cloud |
| 🔵 **Google AI** | Gemini 2.5 Pro/Flash, 2.0 Flash, 1.5 Pro/Flash, Gemma 3 | Cloud |
| 🔗 **OpenRouter** | 100+ models (all providers above + Llama, Mistral, Grok) | Cloud |
| 🟢 **Nvidia NIM** | Llama 3.1 405B/70B/8B, Nemotron 70B/4B, DeepSeek R1 | Cloud |
| 🟠 **Mistral** | Large, Medium, Small, Codestral, Pixtral, Ministral | Cloud |
| 🔷 **DeepSeek** | V3, Coder, R1 Reasoner | Cloud |
| 🟤 **Alibaba** | Qwen Max/Plus/Turbo/VL/Coder, 2.5 72B | Cloud |
| 📱 **Xiaomi** | MiMo V2 Pro, V2 Lite | Cloud |
| 🔥 **Groq** | Llama 3.1/3.3 70B/8B, Mixtral, Gemma, DeepSeek R1 | Cloud |
| 🟡 **Cohere** | Command R+, R, A | Cloud |
| 🟪 **Perplexity** | Sonar Pro, Sonar, Sonar Large/Small | Cloud |
| 🌐 **Together AI** | Llama 3.1 405B/70B, Mixtral 8x22B, Qwen 2.5, DeepSeek R1 | Cloud |
| 🧠 **Cerebras** | Llama 3.1/3.3 8B/70B | Cloud |
| 🟤 **SambaNova** | Llama 3.1 405B/70B, DeepSeek R1/V3, QwQ 32B | Cloud |
| 🎆 **Fireworks** | Llama 3.1 405B/70B, DeepSeek R1, Qwen 2.5 72B | Cloud |
| ✍️ **Writer** | Palmyra X 004, X 003 | Cloud |
| 🟦 **Replicate** | Llama 3.1 405B/70B | Cloud |
| 🟩 **AWS Bedrock** | Claude 3.5, Llama 3.1 405B/70B | Cloud |
| 🔶 **Google Vertex** | Gemini 2.5 Pro, 2.0 Flash, 1.5 Pro | Cloud |
| 🌙 **Moonshot** | Kimi 128K, 32K, 8K | Cloud |
| 🟫 **Zhipu** | GLM-4 Plus, Flash, 4V Plus | Cloud |
| 🔶 **Baichuan** | Baichuan 4, 3 Turbo | Cloud |
| 🟨 **Yi 01.AI** | Yi Large, Medium, Vision | Cloud |
| 🟥 **MiniMax** | Abab 6.5, 6.5s | Cloud |

### Local Providers
| Provider | Models | Type |
|----------|--------|------|
| 🦙 **Ollama** | Llama 3.1/3.2/3.3, CodeLlama, Mistral, Mixtral, Qwen 2.5, Phi-3, Gemma 2, DeepSeek R1, LLaVA | Local |
| 🖥️ **LM Studio** | Any GGUF model | Local |
| ⚙️ **Custom** | Any OpenAI-compatible API | Custom |

**Total: 150+ models across 35+ providers!**

---

## 🔧 80+ Tools

### 📁 File System (8)
| Tool | Description |
|------|-------------|
| `read_file` | Read file contents |
| `write_file` | Write content to file |
| `list_dir` | List directory contents |
| `search_files` | Search for files by pattern |
| `delete_file` | Delete file or folder |
| `move_file` | Move or rename file |
| `copy_file` | Copy a file |
| `file_info` | Get file details (size, date, type) |

### 🌐 Web (5)
| Tool | Description |
|------|-------------|
| `web_search` | Search the web (DuckDuckGo) |
| `fetch_url` | Fetch and extract URL content |
| `browse_web` | Open URL in browser |
| `download_file_url` | Download file from URL |
| `screenshot_web` | Screenshot a webpage |

### 💻 Code Execution (4)
| Tool | Description |
|------|-------------|
| `run_code` | Execute code in sandbox |
| `run_shell` | Run shell command |
| `run_python` | Run Python script |
| `run_js` | Run JavaScript code |

### 🧠 Memory (4)
| Tool | Description |
|------|-------------|
| `remember` | Save to long-term memory |
| `recall` | Search memory |
| `forget` | Delete memory entry |
| `list_memories` | List all memories |

### 📞 Calls & Contacts (8)
| Tool | Description |
|------|-------------|
| `make_call` | Make a phone call |
| `end_call` | End current call |
| `answer_call` | Answer incoming call |
| `reject_call` | Reject incoming call |
| `get_call_log` | Get call history |
| `get_contacts` | Get contacts list |
| `add_contact` | Add new contact |
| `block_contact` | Block a number |

### 💬 Messaging (7)
| Tool | Description |
|------|-------------|
| `send_sms` | Send text message |
| `read_sms` | Read SMS messages |
| `send_email` | Send email |
| `send_whatsapp` | Send WhatsApp message |
| `send_telegram` | Send Telegram message |
| `share_content` | Share to any app |
| `broadcast_sms` | Send SMS to multiple contacts |

### ⏰ Alarms & Scheduling (8)
| Tool | Description |
|------|-------------|
| `set_alarm` | Set alarm with days, label, ringtone |
| `delete_alarm` | Delete an alarm |
| `get_alarms` | List all alarms |
| `start_timer` | Start countdown timer |
| `stop_timer` | Stop running timer |
| `set_reminder` | Set a reminder with repeat |
| `get_calendar` | Get calendar events |
| `add_calendar` | Add calendar event |

### 📱 Phone Control (20!)
| Tool | Description |
|------|-------------|
| `set_brightness` / `get_brightness` | Screen brightness |
| `set_volume` / `get_volume` | Volume control |
| `toggle_wifi` / `get_wifi_info` | WiFi control |
| `toggle_bluetooth` / `get_bluetooth_devices` | Bluetooth control |
| `toggle_mobile_data` | Mobile data |
| `toggle_airplane_mode` | Airplane mode |
| `toggle_flashlight` | Flashlight |
| `toggle_hotspot` | WiFi hotspot |
| `toggle_do_not_disturb` | DND mode |
| `toggle_auto_rotate` | Screen rotation |
| `set_screen_timeout` | Screen timeout |
| `lock_screen` | Lock the screen |
| `take_screenshot` | Screenshot |
| `record_screen` | Screen recording |
| `set_wallpaper` | Set wallpaper |
| `set_ringtone` | Set ringtone |

### 📱 App Management (6)
| Tool | Description |
|------|-------------|
| `open_app` | Open any app |
| `close_app` | Force close app |
| `list_apps` | List installed apps |
| `install_app` | Install APK |
| `uninstall_app` | Uninstall app |
| `app_info` | Get app details |

### 📍 Location & Maps (5)
| Tool | Description |
|------|-------------|
| `get_location` | Get GPS location |
| `get_address` | Get address from coordinates |
| `open_maps` | Open maps with directions |
| `share_location` | Share live location |
| `geofence` | Set location alert |

### 📸 Camera & Media (8)
| Tool | Description |
|------|-------------|
| `take_photo` | Take photo (front/back) |
| `record_video` | Record video |
| `get_gallery` | Get photos from gallery |
| `delete_photo` | Delete a photo |
| `scan_qr` | Scan QR/barcode |
| `generate_qr` | Generate QR code |
| `get_storage_info` | Get storage usage |
| `screen_brightness_auto` | Auto brightness |

### 🔊 Media Playback (5)
| Tool | Description |
|------|-------------|
| `play_music` | Play audio file |
| `pause_music` | Pause playback |
| `stop_music` | Stop playback |
| `next_track` | Next track |
| `text_to_speech` | Speak text aloud |

### 🔐 Security (4)
| Tool | Description |
|------|-------------|
| `authenticate` | Biometric authentication |
| `check_biometric` | Check biometric availability |
| `encrypt_data` | Encrypt data |
| `decrypt_data` | Decrypt data |

### 📊 Device Info (6)
| Tool | Description |
|------|-------------|
| `get_device_info` | Full device info |
| `get_battery` | Battery level & status |
| `get_network_info` | Network & IP info |
| `get_running_processes` | Running processes |
| `get_system_settings` | System settings |
| `vibrate` | Vibrate device |

### 🖥️ Remote Control (10!)
| Tool | Description |
|------|-------------|
| `remote_connect` | Connect to remote device (SSH) |
| `remote_disconnect` | Disconnect |
| `remote_shell` | Run command on remote |
| `remote_file_read` | Read file from remote |
| `remote_file_write` | Write file to remote |
| `remote_file_list` | List remote files |
| `remote_screenshot` | Screenshot remote screen |
| `remote_keyboard` | Send keystrokes |
| `remote_mouse` | Move/click mouse |
| `remote_clipboard` | Get/set clipboard |

### 🔗 Integration (5)
| Tool | Description |
|------|-------------|
| `http_request` | Make HTTP API call |
| `create_note` | Create a note |
| `create_todo` | Create todo item |
| `translate_text` | Translate text |
| `clipboard_copy` | Copy to clipboard |

### 🤖 Automation (5)
| Tool | Description |
|------|-------------|
| `create_workflow` | Create automation |
| `run_workflow` | Run automation |
| `list_workflows` | List automations |
| `create_routine` | Create daily routine |
| `if_this_then_that` | IFTTT-style rule |

### 🎮 External (3)
| Tool | Description |
|------|-------------|
| `read_nfc` | Read NFC tag |
| `write_nfc` | Write NFC tag |
| `control_smart_home` | Control smart devices |

---

## ⚡ 110+ Skills

| Category | Count | Examples |
|----------|-------|---------|
| 💻 Development | 15 | Code Review, Debug, Code Gen, SQL, Regex, Git, Docker |
| ✍️ Writing | 15 | Email, Essay, Story, Translate, Resume, Blog, Scripts |
| 📊 Analysis | 10 | Data Analysis, Research, Market Research, SWOT |
| 🎓 Education | 10 | Math, Science, History, Flashcards, Quiz, Language |
| 💼 Business | 10 | Business Plan, Pitch Deck, Budget, Invoice, KPI |
| 🎨 Creative | 10 | Logo, Colors, UI Design, Recipes, Travel, Fashion |
| 🛠️ Productivity | 10 | Todo, Calendar, Notes, Goals, Focus, Workflow |
| 🤖 AI & Tech | 8 | Prompt Engineer, Cybersecurity, Cloud, Database |
| 🏥 Health | 5 | Fitness, Nutrition, Mental Health, Sleep, Meditation |
| 🎮 Fun | 8 | Trivia, Jokes, Riddles, Games, Roleplay |
| 📱 Social | 6 | Tweet, Instagram, LinkedIn, YouTube, TikTok |
| 🔬 Research | 5 | Academic, Literature Review, Citations |
| ⚖️ Legal | 3 | Legal Basics, Privacy, Terms of Service |

---

## 📥 Download AI Models to Your Phone

Run AI models directly on your Android device — no internet needed!

| Family | Models | Size | RAM Needed |
|--------|--------|------|------------|
| 🔵 **Gemma** | 1B, 4B, 12B, 27B | 800MB - 16GB | 2-16GB |
| 🦙 **Llama** | 3.2 1B/3B, 3.1 8B | 700MB - 4.7GB | 2-6GB |
| 🟦 **Phi** | Phi-4 Mini, Phi-3.5 Mini | 2.3-2.4GB | 4GB |
| 🟤 **Qwen** | 0.5B, 1.5B, 3B, 7B | 400MB - 4.5GB | 1-6GB |
| 🟠 **Mistral** | 7B, Nemo 12B | 4.1-7GB | 6-8GB |
| 🔷 **DeepSeek R1** | 1.5B, 7B | 1.1-4.5GB | 2-6GB |
| 🤗 **SmolLM** | 1.7B | 1GB | 2GB |
| 👁️ **LLaVA** | Phi-3 Vision | 2.8GB | 4GB |

**Import options**: HuggingFace URL, local GGUF file, custom endpoint

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      DroidClaw Gateway                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐             │
│  │  Provider   │  │   Agent    │  │   Auto     │             │
│  │  Manager    │──│  Runtime   │──│  Engine    │             │
│  │  (35+ AI)   │  │  (Tool     │  │  (Cron,    │             │
│  └────────────┘  │  Loop)     │  │  Tasks)    │             │
│                  └────────────┘  └────────────┘             │
│        │               │               │                     │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐             │
│  │   Skill    │  │   Tool     │  │   Voice    │             │
│  │  Engine    │  │  Engine    │  │  Engine    │             │
│  │  (110+)    │  │  (80+)     │  │  (STT/TTS) │             │
│  └────────────┘  └────────────┘  └────────────┘             │
│        │               │               │                     │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐             │
│  │   Local    │  │   File     │  │  Memory    │             │
│  │  Models    │  │  Manager   │  │  Engine    │             │
│  │  (20+)     │  │  (Upload/  │  │  (SQLite)  │             │
│  └────────────┘  │  Download) │  └────────────┘             │
│                  └────────────┘                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 🎨 UI Screens

### 🎉 Onboarding (6 pages)
Welcome → 20+ Providers → 110+ Skills → 52+ Tools → Local Models → Get Started

### 💬 Chat (ChatGPT-style)
- "What can I help you with?" welcome
- Quick suggestion chips
- Real-time task tracking
- Voice input/output
- File upload (images, videos, documents)
- File download (save any response)
- Model swap mid-conversation

### ⚡ Skills Browser
- 110+ skills across 13 categories
- Search & filter
- Enable/disable per skill
- Skill details with triggers

### 🔧 Tools Dashboard
- 80+ tools across 16 categories
- Category grouping
- Tool status indicators

### 🧠 Memory Browser
- Long-term memory entries
- Knowledge base
- Conversation history
- Search & manage

### 📥 Local Models
- Browse 20+ phone-ready models
- Download with progress
- Import via URL or GGUF file
- Manage downloaded models

### 🔄 Automation
- Create reminders
- Schedule recurring tasks
- IFTTT-style rules
- Daily routines

### ⚙️ Settings (14 sections, 100+ options)
- AI Provider & Model
- API Keys
- Local Models
- Channels (WebChat, Telegram, WhatsApp, Discord, Signal, Email, SMS)
- Agent Behavior
- Voice & Audio
- Phone Control
- Notifications
- Appearance
- Security & Privacy
- Storage & Data
- Automation
- Developer
- About

---

## 🔨 Build Your APK

### Prerequisites

1. **Install Flutter SDK** (3.x or later)
   ```bash
   # macOS
   brew install flutter

   # Linux
   sudo snap install flutter --classic

   # Windows
   # Download from https://docs.flutter.dev/get-started/install/windows
   ```

2. **Install Android Studio**
   - Download from https://developer.android.com/studio
   - Install Android SDK (API 34+)
   - Install Android Build Tools

3. **Set up Android device or emulator**
   - Enable Developer Options on your Android phone
   - Enable USB Debugging
   - Connect via USB or set up wireless debugging

### Step-by-Step Build

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/droidclaw.git
cd droidclaw

# 2. Install dependencies
flutter pub get

# 3. Check Flutter setup
flutter doctor

# 4. Connect your Android device (USB or wireless)
flutter devices

# 5. Run in debug mode (for testing)
flutter run

# 6. Build release APK
flutter build apk --release

# 7. Find your APK
# Location: build/app/outputs/flutter-apk/app-release.apk
```

### Transfer APK to Phone

```bash
# Method 1: ADB install
adb install build/app/outputs/flutter-apk/app-release.apk

# Method 2: Transfer via USB
cp build/app/outputs/flutter-apk/app-release.apk /path/to/phone/

# Method 3: Share via cloud
# Upload to Google Drive / Dropbox and download on phone
```

### Quick Build Script

```bash
#!/bin/bash
echo "🤖 Building DroidClaw APK..."
flutter clean
flutter pub get
flutter build apk --release --split-per-abi

echo "✅ Build complete!"
echo "📱 APK locations:"
echo "   ARM64: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
echo "   ARMv7: build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
echo "   x86_64: build/app/outputs/flutter-apk/app-x86_64-release.apk"
echo ""
echo "📱 Install on connected device:"
echo "   adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
```

---

## ⚙️ Configuration

### Add API Keys

1. Open DroidClaw → Settings ⚙️
2. Go to **API Keys**
3. Enter keys for your providers:
   - OpenAI: `sk-...`
   - Anthropic: `sk-ant-...`
   - Google: `AIza...`
   - OpenRouter: `sk-or-...`
   - etc.

### Use Local Models

1. Go to Settings → **Local Models**
2. Browse available models
3. Download one (e.g., Gemma 3 4B)
4. Set as active model
5. Chat without internet!

### Connect Remote Devices

1. Ensure SSH is enabled on your laptop/PC
2. Use the `remote_connect` tool
3. Enter host, port, credentials
4. Control remotely from your phone!

---

## 📁 Project Structure

```
droidclaw/
├── lib/
│   ├── main.dart                              # Entry point + onboarding
│   ├── core/
│   │   ├── gateway/droidclaw_gateway.dart     # 🧠 Central brain
│   │   ├── providers/ai_provider_manager.dart # 🤖 35+ AI providers
│   │   ├── tools/tool_engine.dart             # 🔧 80+ tools
│   │   ├── skills/skill_engine.dart           # ⚡ 110+ skills
│   │   ├── memory/memory_engine.dart          # 🧠 SQLite memory
│   │   ├── voice/voice_engine.dart            # 🎤 STT & TTS
│   │   ├── automation/automation_engine.dart  # 🔄 Cron & tasks
│   │   ├── search/web_search_engine.dart      # 🌐 Web search
│   │   ├── models/local_model_manager.dart    # 📥 Local models
│   │   └── files/file_manager.dart            # 📁 File management
│   └── ui/
│       ├── theme/droid_theme.dart             # 🎨 Cyberpunk theme
│       └── screens/
│           ├── home_screen.dart               # 🏠 Navigation
│           ├── chat_screen.dart               # 💬 Agent chat
│           ├── skills_screen.dart             # ⚡ Skills
│           ├── tools_screen.dart              # 🔧 Tools
│           ├── memory_screen.dart             # 🧠 Memory
│           ├── automation_screen.dart         # 🔄 Automation
│           ├── settings_screen.dart           # ⚙️ Settings
│           ├── onboarding_screen.dart         # 🎉 Welcome
│           └── local_models_screen.dart       # 📥 Downloads
├── android/                                   # Android config
├── assets/                                    # Icons, fonts
├── pubspec.yaml                               # Dependencies
└── README.md                                  # This file
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

## 📝 License

MIT License — Inspired by [OpenClaw](https://github.com/openclaw/openclaw)

---

## 🙏 Acknowledgments

- [OpenClaw](https://github.com/openclaw/openclaw) — The inspiration
- [Flutter](https://flutter.dev) — The framework
- [Ollama](https://ollama.ai) — Local model runtime
- [HuggingFace](https://huggingface.co) — Model hosting

---

<p align="center">
  <b>🤖 DroidClaw — The power of OpenClaw, in your pocket</b><br/>
  <i>Can do ANYTHING on your phone</i>
</p>
