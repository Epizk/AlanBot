#!/bin/bash

# --- ALANBOT SUITE v5.1.1 (Bugfix & Clean Install) ---
# Features: Qwen 2.5 Coder, Llama 3.2, Auto-Cleanup of old models.

# --- COLORS ---
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

INSTALL_DIR="$HOME/.alanbot"
HISTORY_DIR="$HOME/.alanbot/history"
CONFIG_FILE="$HOME/.alanbot/config.json"
BIN_ALANBOT="/usr/local/bin/alanbot"
BIN_MENU="/usr/local/bin/menu-alanbot"

# --- AI MODELS ---
# Coding: Qwen 2.5 Coder (State of the Art for local coding)
MODEL_CODE="qwen2.5-coder:7b"
# Chat: Llama 3.2 (Best for general chat/math)
MODEL_CHAT="llama3.2" 
# Old Model to remove (Save space)
MODEL_OLD="deepseek-coder:6.7b"

# --- HELPER FUNCTIONS ---

loading_bar() {
    local msg="$1"
    echo -ne "\n${BOLD}${PURPLE}[*] $msg${RESET}\n"
    for ((i=0; i<=100; i+=10)); do
        printf "\r${PURPLE}[%-10s] %d%%${RESET}" "$(head -c $((i/10)) < /dev/zero | tr '\0' '█')" "$i"
        sleep 0.1
    done
    echo -e " ${GREEN}✔ DONE${RESET}\n"
}

show_header() {
    clear
    echo -e "${PURPLE}"
    echo "    ___    __              ____        __ "
    echo "   /   |  / /___ _____    / __ )____  / /_"
    echo "  / /| | / / __ \`/ __ \  / __  / __ \/ __/"
    echo " / ___ |/ / /_/ / / / / / /_/ / /_/ / /_  "
    echo "/_/  |_/_/\__,_/_/ /_/ /_____/\____/\__/  "
    echo -e "${CYAN}   :: INSTALLER v5.1.1 (Clean Build) ::${RESET}\n"
}

generate_core_files() {
    mkdir -p "$HISTORY_DIR"
    
    # 1. GENERATE THE PYTHON BRAIN (Bugfix: Added error handling for config)
    cat << 'PY_EOF' > "$INSTALL_DIR/alanbot.py"
import sys, os, json, re, ollama, datetime, time
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel
from rich.live import Live
from rich.prompt import Prompt

# CONFIG
HISTORY_DIR = os.path.expanduser("~/.alanbot/history")
CONFIG_FILE = os.path.expanduser("~/.alanbot/config.json")
console = Console()

# PROMPTS
SYS_CODER = "You are a Qwen-powered Coding Assistant. Output Markdown code blocks. Be concise. Solve the problem accurately."
SYS_CHAT = "You are AlanBot, a helpful assistant. Answer questions, do math, and be friendly. You can write code if asked."

def load_config():
    # Bugfix: Create default config if missing
    default_conf = {"current_session": "default", "model": "llama3.2", "mode": "chat"}
    if not os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, 'w') as f:
                json.dump(default_conf, f)
        except:
            pass
        return default_conf
        
    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except:
        return default_conf

def save_history(session_name, history, model, mode):
    if not os.path.exists(HISTORY_DIR):
        os.makedirs(HISTORY_DIR)
        
    filepath = os.path.join(HISTORY_DIR, f"{session_name}.json")
    data = {
        "timestamp": str(datetime.datetime.now()),
        "model": model,
        "mode": mode,
        "history": history
    }
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=4)

def load_history(session_name):
    filepath = os.path.join(HISTORY_DIR, f"{session_name}.json")
    if os.path.exists(filepath):
        try:
            with open(filepath, 'r') as f:
                data = json.load(f)
                return data["history"], data.get("model", "llama3.2"), data.get("mode", "chat")
        except:
            return [], None, None
    return [], None, None

def clean_output(text):
    return text.replace("<```", "```").replace("```>", "```")

def main():
    config = load_config()
    session_name = config.get("current_session", "default")
    
    history, saved_model, saved_mode = load_history(session_name)
    
    # Priority: Saved Model > Config Model
    model = saved_model if saved_model else config.get("model", "llama3.2")
    mode = saved_mode if saved_mode else config.get("mode", "chat")
    
    sys_prompt = SYS_CODER if mode == "code" else SYS_CHAT
    
    console.clear()
    header = f"🐰 ALANBOT | Session: {session_name} | 🧠 {model}"
    console.print(Panel(header, style="bold magenta", border_style="purple"))
    
    if history:
        console.print("[dim]Resuming conversation...[/dim]")
        for msg in history[-2:]:
            role = "YOU" if msg['role'] == 'user' else "ALANBOT"
            color = "white" if msg['role'] == 'user' else "bright_magenta"
            console.print(f"[{color}][{role}]: {msg['content'][:100]}...[/{color}]")
    else:
        console.print("[dim]New conversation started.[/dim]")

    while True:
        try:
            user = Prompt.ask("\n[bold purple]>>[/bold purple]")
            
            if user.lower() in ['exit', 'quit']: break
            if user.lower() == 'clear': console.clear(); continue
            if not user.strip(): continue

            history.append({'role': 'user', 'content': user})
            
            with Live(Panel("Thinking...", style="dim purple"), refresh_per_second=10) as live:
                full_resp = ""
                msgs_to_send = [{'role':'system', 'content':sys_prompt}] + history
                
                try:
                    stream = ollama.chat(model=model, messages=msgs_to_send, stream=True)
                    for chunk in stream:
                        content = chunk['message']['content']
                        full_resp += content
                        live.update(Panel(Markdown(clean_output(full_resp)), title="AlanBot"))
                    
                    history.append({'role': 'assistant', 'content': clean_output(full_resp)})
                    save_history(session_name, history, model, mode)
                except Exception as e:
                    console.print(f"[red]Error connecting to AI: {e}[/red]")
                    console.print("[yellow]Make sure Ollama is running (sudo systemctl start ollama)[/yellow]")
                    break

        except KeyboardInterrupt:
            save_history(session_name, history, model, mode)
            print("\nSaved & Exiting.")
            break

if __name__ == "__main__":
    main()
PY_EOF

    # 2. GENERATE THE MENU MANAGER
    cat << 'MENU_EOF' > "$INSTALL_DIR/menu.py"
import os, json
from rich.console import Console
from rich.panel import Panel
from rich.prompt import Prompt

CONFIG_FILE = os.path.expanduser("~/.alanbot/config.json")
HISTORY_DIR = os.path.expanduser("~/.alanbot/history")
console = Console()

def update_config(session, model, mode):
    data = {"current_session": session, "model": model, "mode": mode}
    with open(CONFIG_FILE, 'w') as f:
        json.dump(data, f)

def get_saved_sessions():
    if not os.path.exists(HISTORY_DIR): return []
    files = [f.replace(".json", "") for f in os.listdir(HISTORY_DIR) if f.endswith(".json")]
    return sorted(files)

def main():
    console.clear()
    console.print(Panel("🐰 ALANBOT MENU SYSTEM (v5.1)", style="bold magenta"))
    
    console.print("[1] New Chat (🧠 General/Math) - Llama 3.2")
    console.print("[2] New Chat (💻 High-Perf Coding) - Qwen 2.5 Coder")
    console.print("[3] Resume Conversation")
    console.print("[4] Exit")
    
    choice = Prompt.ask("\nSelect", choices=["1", "2", "3", "4"])
    
    if choice == "1":
        name = Prompt.ask("Name this session", default="chat_1")
        update_config(name, "llama3.2", "chat")
        console.print(f"[green]Session '{name}' created![/green] Run 'alanbot' to start.")
        
    elif choice == "2":
        name = Prompt.ask("Name this session", default="code_1")
        update_config(name, "qwen2.5-coder:7b", "code")
        console.print(f"[green]Session '{name}' created![/green] Run 'alanbot' to start.")
        
    elif choice == "3":
        sessions = get_saved_sessions()
        if not sessions:
            console.print("[red]No saved chats found.[/red]")
            return
        
        console.print("\nSaved Chats:")
        for i, s in enumerate(sessions):
            console.print(f"[{i+1}] {s}")
            
        idx = Prompt.ask("Select number", default="1")
        try:
            selected = sessions[int(idx)-1]
            update_config(selected, "llama3.2", "chat") 
            console.print(f"[green]Resuming '{selected}'...[/green] Run 'alanbot' to start.")
        except:
            console.print("[red]Invalid selection[/red]")

    elif choice == "4":
        console.print("Goodbye.")

if __name__ == "__main__":
    main()
MENU_EOF
}

do_install() {
    # 1. CHECK OLLAMA
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}Error: Install Ollama first.${RESET}"
        exit 1
    fi

    # 2. MODEL CLEANUP & UPDATE
    echo -e "${CYAN}Checking AI Model Integrity...${RESET}"
    
    # REMOVE OLD DEEPSEEK IF EXISTS (To save space)
    if ollama list | grep -q "$MODEL_OLD"; then
        echo -e "${YELLOW}Removing old model ($MODEL_OLD) to save space...${RESET}"
        ollama rm "$MODEL_OLD"
    fi

    # FORCE PULL QWEN (Coding)
    echo -e "${PURPLE}Updating/Downloading Coding Brain ($MODEL_CODE)...${RESET}"
    ollama pull "$MODEL_CODE"

    # FORCE PULL LLAMA (Chat)
    echo -e "${PURPLE}Updating/Downloading Chat Brain ($MODEL_CHAT)...${RESET}"
    ollama pull "$MODEL_CHAT"

    # 3. GENERATE FILES
    loading_bar "Installing System Files..." 2
    
    # Bugfix: Remove old environment to ensure fresh dependencies
    if [ -d "$INSTALL_DIR/ai_env" ]; then
        rm -rf "$INSTALL_DIR/ai_env"
    fi
    
    generate_core_files

    # 4. SETUP ENV
    echo -e "${CYAN}Setting up Python Environment...${RESET}"
    cd "$INSTALL_DIR"
    python3 -m venv ai_env
    source ai_env/bin/activate
    pip install --upgrade pip ollama rich pyperclip > /dev/null 2>&1

    # 5. CREATE LAUNCHERS
    cat << RUN_EOF > "$INSTALL_DIR/run_alanbot.sh"
#!/bin/bash
source "$INSTALL_DIR/ai_env/bin/activate"
python3 "$INSTALL_DIR/alanbot.py"
RUN_EOF
    chmod +x "$INSTALL_DIR/run_alanbot.sh"

    cat << MENU_EOF > "$INSTALL_DIR/run_menu.sh"
#!/bin/bash
source "$INSTALL_DIR/ai_env/bin/activate"
python3 "$INSTALL_DIR/menu.py"
MENU_EOF
    chmod +x "$INSTALL_DIR/run_menu.sh"

    # 6. SYMLINKS (Bugfix: Better sudo handling)
    echo -e "${PURPLE}[sudo] Creating global commands...${RESET}"
    
    if [ -L "$BIN_ALANBOT" ] || [ -f "$BIN_ALANBOT" ]; then 
        sudo rm "$BIN_ALANBOT"
    fi
    if [ -L "$BIN_MENU" ] || [ -f "$BIN_MENU" ]; then 
        sudo rm "$BIN_MENU"
    fi
    
    sudo ln -s "$INSTALL_DIR/run_alanbot.sh" "$BIN_ALANBOT"
    sudo ln -s "$INSTALL_DIR/run_menu.sh" "$BIN_MENU"

    echo -e "\n${GREEN}✔ INSTALLATION COMPLETE${RESET}"
    echo -e "Type ${BOLD}menu-alanbot${RESET} to initialize."
}

do_uninstall() {
    rm -rf "$INSTALL_DIR"
    if [ -f "$BIN_ALANBOT" ]; then sudo rm "$BIN_ALANBOT"; fi
    if [ -f "$BIN_MENU" ]; then sudo rm "$BIN_MENU"; fi
    echo "Uninstalled."
}

# --- MENU ---
show_header
echo "1) Install / Repair (Force Update Models)"
echo "2) Uninstall"
echo "3) Exit"
read -p ">> " choice

case $choice in
    1) do_install ;;
    2) do_uninstall ;;
    3) exit ;;
esac
