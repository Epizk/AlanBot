# 🐰 AlanBot (Terminal AI Assistant)

**Copyright (c) 2025 AlanBot**

**AlanBot** is a professional, 100% OFFLINE AI coding assistant designed for Linux terminals. It runs the powerful **DeepSeek Coder** model directly on your hardware, ensuring your code and data never leave your machine.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-green.svg)
![Version](https://img.shields.io/badge/version-v4.1-purple.svg)

## ⚡ Features

* **100% Offline:** Runs locally via Ollama. No internet required after installation.
* **3 Operation Modes:**
    * **💻 Coding Only:** Strict, fast, no chit-chat.
    * **🗣️ Questions:** Good for explanations and general help.
    * **🚀 Hybrid:** The smartest mode—can chat AND write code (Recommended).
* **Smart Fixes:** Automatically sanitizes output to prevent common formatting errors (like broken code blocks).
* **Cyberpunk UI:** Features retro loading screens and a beautiful terminal interface.
* **Clipboard Ready:** Type `copy` to instantly grab code blocks.
* **Global Command:** Run `alanbot` from any directory on your computer.

---

## 📋 Prerequisites

Before you begin, you need two things installed on your Linux machine:

1.  **Python 3** (Most Linux systems have this already).
2.  **Ollama**: This is the engine that runs the AI model.
    * *To install Ollama, open a terminal and run:*
        ```bash
        curl -fsSL [https://ollama.com/install.sh](https://ollama.com/install.sh) | sh
        ```

---

## 💿 Installation Guide (Step-by-Step)

Follow these exact steps to set up AlanBot.

### Step 1: Download the Installer
Download the file `setup_alanbot.sh` and save it to a folder on your computer (e.g., your Home folder or Downloads).

### Step 2: Open Terminal
Open your terminal and navigate to the folder where you saved the file.
* *Example (if you saved it in Downloads):*
    ```bash
    cd ~/Downloads
    ```

### Step 3: Make it Executable
Run this command to give the file permission to run:
```bash
chmod +x setup_alanbot.sh

###Final step: Run it
Use this to run it ./setup_alanbot.sh
