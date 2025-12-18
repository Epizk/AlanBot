#!/bin/bash

# --- ALANBOT SUITE v5.0 ---
# Features: Dual Models (Chat vs Code), Save System, Switcher Menu

# --- COLORS ---
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
BOLD='\033[1m'
RESET='\033[0m'

INSTALL_DIR="$HOME/.alanbot"
HISTORY_DIR="$HOME/.alanbot/history"
CONFIG_FILE="$HOME/.alanbot/config.json"
BIN_ALANBOT="/usr/local/bin/alanbot"
BIN_MENU="/usr/local/bin/menu-alanbot"

# MODELS
MODEL_CODE="deepseek-coder:6.7b"
MODEL_CHAT="llama3.2" 

# --- INSTALLER FUNCTIONS ---

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
    echo -e "${CYAN}      :: SYSTEM INSTALLER v5.0 ::${RESET}\n"
}

generate_python_core() {
    mkdir -p "$HISTORY_DIR"
    
    # 1. GENERATE THE PYTHON BRAIN
    cat << 'PY_EOF' > "$INSTALL_DIR/alanbot.py"
import sys, os, json, re, ollama, argparse, datetime
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
SYS_CODER = "You are a strict Coding Assistant. Output Markdown code blocks. Do not chat unnecessarily."
SYS_CHAT = "You are AlanBot, a helpful assistant. Answer questions, do math, and be friendly. You can write code if asked."

def load_config():
    if not os.path.exists(CONFIG_FILE):
        return {"current_session": "default", "model": "llama3.2", "mode": "chat"}
    with open(CONFIG_FILE, 'r') as f:
        return json.load(f)

def save_history(session_name, history, model, mode):
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
        with open(filepath, 'r') as f:
            data = json.load(f)
            return data["history"], data.get("model", "llama3.2"), data.get("mode", "chat")
    return [], None, None

def clean_output(text):
    return text.replace("<```", "```").replace("```>", "```")

def main():
    # Load settings
    config = load_config()
    session_name = config["current_session"]
    
    # Load previous chat
    history, saved_model, saved_mode = load_history(session_name)
    
    # Determine Model/Mode (Saved takes precedence if resuming)
    model = saved_model if saved_model else config["model"]
    mode = saved_mode if saved_mode else config["mode"]
    
    # Select System Prompt
    sys_prompt = SYS_CODER if mode == "code" else SYS_CHAT
    
    console.clear()
    header = f"🐰 ALANBOT | Session: {session_name} | 🧠 {model}"
    console.print(Panel(header, style="bold magenta", border_style="purple"))
    
    # Replay last few messages for context visual
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
                # Inject System Prompt dynamically
                msgs_to_send = [{'role':'system', 'content':sys_prompt}] + history
                
                stream = ollama.chat(model=model, messages=msgs_to_send, stream=True)
                
                for chunk in stream:
                    content = chunk['message']['content']
                    full_resp += content
                    live.update(Panel(Markdown(clean_output(full_resp)), title="AlanBot"))
                
                history.append({'role': 'assistant', 'content': clean_output(full_resp)})
                save_history(session_name, history, model, mode)

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
    console.print(Panel("🐰 ALANBOT MENU SYSTEM", style="bold magenta"))
    
    console.print("[1] Start New Chat (🧠 General/Math) - Uses Llama3.2")
    console.print("[2] Start New Chat (💻 Coding Strict) - Uses DeepSeek")
    console.print("[3] Resume Previous Conversation")
    console.print("[4] Exit")
    
    choice = Prompt.ask("\nSelect", choices=["1", "2", "3", "4"])
    
    if choice == "1":
        name = Prompt.ask("Name this session", default="chat_1")
        update_config(name, "llama3.2", "chat")
        console.print(f"[green]Session '{name}' created![/green] Run 'alanbot' to start.")
        
    elif choice == "2":
        name = Prompt.ask("Name this session", default="code_1")
        update_config(name, "deepseek-coder:6.7b", "code")
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
            # We assume resumed chats keep their old model settings
            # But we need to set the config so 'alanbot' knows which file to open
            # We essentially just update the target file
            update_config(selected, "llama3.2", "chat") # Defaults, will be overwritten by load logic
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

    # 2. CHECK/DOWNLOAD MODELS
    echo -e "${CYAN}Checking AI Models...${RESET}"
    
    # Pull Coding Brain
    if ! ollama list | grep -q "$MODEL_CODE"; then
        echo -e "${PURPLE}Downloading Coding Brain ($MODEL_CODE)...${RESET}"
        ollama pull "$MODEL_CODE"
    else
        echo -e "${GREEN}✔ Coding Brain Ready${RESET}"
    fi

    # Pull Chat Brain (Fixes the "I am just a robot" issue)
    if ! ollama list | grep -q "$MODEL_CHAT"; then
        echo -e "${PURPLE}Downloading Chat Brain ($MODEL_CHAT)...${RESET}"
        ollama pull "$MODEL_CHAT"
    else
        echo -e "${GREEN}✔ Chat Brain Ready${RESET}"
    fi

    # 3. GENERATE FILES
    loading_bar "Installing System Files..." 2
    rm -rf "$INSTALL_DIR"
    generate_python_core

    # 4. SETUP ENV
    cd "$INSTALL_DIR"
    python3 -m venv ai_env
    source ai_env/bin/activate
    pip install ollama rich pyperclip > /dev/null 2>&1

    # 5. CREATE LAUNCHERS
    # Main Launcher
    cat << RUN_EOF > "$INSTALL_DIR/run_alanbot.sh"
#!/bin/bash
source "$INSTALL_DIR/ai_env/bin/activate"
python3 "$INSTALL_DIR/alanbot.py"
RUN_EOF
    chmod +x "$INSTALL_DIR/run_alanbot.sh"

    # Menu Launcher
    cat << MENU_EOF > "$INSTALL_DIR/run_menu.sh"
#!/bin/bash
source "$INSTALL_DIR/ai_env/bin/activate"
python3 "$INSTALL_DIR/menu.py"
MENU_EOF
    chmod +x "$INSTALL_DIR/run_menu.sh"

    # 6. SYMLINKS
    if [ -f "$BIN_ALANBOT" ]; then sudo rm "$BIN_ALANBOT"; fi
    if [ -f "$BIN_MENU" ]; then sudo rm "$BIN_MENU"; fi
    
    echo -e "${PURPLE}[sudo] Creating global commands...${RESET}"
    sudo ln -s "$INSTALL_DIR/run_alanbot.sh" "$BIN_ALANBOT"
    sudo ln -s "$INSTALL_DIR/run_menu.sh" "$BIN_MENU"

    echo -e "\n${GREEN}✔ INSTALLATION COMPLETE${RESET}"
    echo -e "1. Type ${BOLD}menu-alanbot${RESET} to create/switch conversations."
    echo -e "2. Type ${BOLD}alanbot${RESET} to resume the active conversation."
}

do_uninstall() {
    rm -rf "$INSTALL_DIR"
    if [ -f "$BIN_ALANBOT" ]; then sudo rm "$BIN_ALANBOT"; fi
    if [ -f "$BIN_MENU" ]; then sudo rm "$BIN_MENU"; fi
    echo "Uninstalled."
}

# --- MENU ---
show_header
echo "1) Install AlanBot v5.0 (Dual Brain & Save System)"
echo "2) Uninstall"
echo "3) Exit"
read -p ">> " choice

case $choice in
    1) do_install ;;
    2) do_uninstall ;;
    3) exit ;;
esac
