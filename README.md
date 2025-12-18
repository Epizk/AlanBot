# 🐰 AlanBot v5.1 (Performance Upgrade)

**Copyright (c) 2025 AlanBotDev**

**AlanBot** is a professional, persistent, and 100% OFFLINE AI companion for Linux. Version 5.1 introduces the **Qwen 2.5 Coder** model, which offers state-of-the-art local programming capabilities, alongside **Llama 3.2** for general conversation.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-green.svg)
![Version](https://img.shields.io/badge/version-v5.1-purple.svg)

> [!WARNING]
> **⚠️ IMPORTANT: HIGH DATA USAGE ⚠️**
> This installation will download approximately **10GB of data**.
> It must pull two distinct AI neural networks (`qwen2.5-coder` and `llama3.2`) to your machine to function. Ensure you have a stable internet connection and sufficient disk space before running the setup.

---

## ⚡ Features

* **Dual-Brain Intelligence:**
    * 🧠 **Chat Mode (Llama 3.2):** Friendly, excellent at math, creative writing, and general explanations.
    * 💻 **Code Mode (Qwen 2.5 Coder):** High-performance programming logic. Beats GPT-4 in many local coding benchmarks.
* **Save System:** Conversations are saved to JSON files automatically. You can close your terminal and resume exactly where you left off later.
* **100% Offline:** Zero data leaks. Your code never leaves your machine.
* **Manager Menu:** A dedicated tool to create, switch, and manage different conversation threads.

---

## 📋 Prerequisites

1.  **Linux OS** (Ubuntu, Debian, Arch, etc.)
2.  **Python 3**
3.  **Ollama:** The engine required to run the AI models.
    * *If you don't have it, run:* `curl -fsSL https://ollama.com/install.sh | sh`

---

## 💿 Installation Guide

### Step 1: Download
Download the `setup_alanbot.sh` file to a folder on your computer.

### Step 2: Set Permissions
Open your terminal, go to the folder, and make the script executable:
```bash
chmod +x setup_alanbot.sh
./setup_alanbot.sh
