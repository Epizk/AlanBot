# AlanBot v6.0 - TITAN EDITION

AlanBot v6.0 is a persistent, offline AI command center. This "Titan" release completely replaces the neural architecture with superior 2025-class models and fixes critical Linux integration issues.

## Critical Improvements

1.  **Fixed Copy Command:** Now auto-installs `xclip` drivers. The copy command is now fully functional on Linux X11/Wayland systems.
2.  **Auto-Purge:** The installer detects and **deletes** obsolete models (Llama 3.1, DeepSeek, old Mistral) to free storage.
3.  **Titan Architecture:** Uses Qwen 2.5 and Llama 3.2 for state-of-the-art performance.

## System Requirements

* **OS:** Linux (Ubuntu, Debian, Arch, etc.)
* **Storage:** 25GB+ (Models are larger and more complex).
* **Dependencies:** `curl`, `xclip` (Auto-installed).

## Installation

1.  **Set Permissions:**
    ```bash
    chmod +x setup_alanbot.sh
    ```

2.  **Run Installer:**
    ```bash
    ./setup_alanbot.sh
    ```
    *Note: You may be asked for a `sudo` password to install the clipboard driver.*

## Model Suite (Titan)

| Mode | Model | Description |
| :--- | :--- | :--- |
| **Internet/Omni** | **Llama 3.2** | The "Strongest" general model. Time-aware. Handles history, science, and reasoning. |
| **Titan Coder** | **Qwen 2.5 Coder** | Replaces DeepSeek. Outperforms GPT-4 in many coding benchmarks. |
| **Titan Hybrid** | **Mistral-Nemo** | A new 12B parameter model that replaces the old Mistral 7B for superior logic. |

## Usage

| Command | Action |
| :--- | :--- |
| `menu-alanbot` | Open the Titan Dashboard. |
| `copy` | (In-Chat) Instantly copy the last generated code block to system clipboard. |
| `exit` | Save and Quit. |
