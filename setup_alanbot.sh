#!/bin/bash

# --- ALANBOT SUITE v6.0 (TITAN EDITION) ---
# FIX: Installs 'xclip' to fix the copy command
# UPDATE: Swapped to Qwen 2.5 Coder & Mistral-Nemo (2025 Class)
# ACTION: Aggressively removes old v5.x models

# --- COLORS ---
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
BOLD='\033[1m'
RESET='\033[0m'

INSTALL_DIR="$HOME/.alanbot"
HISTORY_DIR="$HOME/.alanbot/history"
BIN_ALANBOT="/usr/local/bin/alanbot"
BIN_MENU="/usr/local/bin/menu-alanbot"

# --- NEW TITAN MODELS (2025 CLASS) ---
MODEL_CODE="qwen2.5-coder:latest"      # The strongest coding model
MODEL_OMNI="llama3.2:latest"           # The newest general intelligence
MODEL_HYBRID="mistral-nemo"            # The new standard for logic/chat

# --- OBSOLETE MODELS (TO DELETE) ---
OLD_MODELS=("llama3.1" "deepseek-coder-v2" "mistral" "deepseek-coder:6.7b" "qwen2.5-coder:7b")

# --- UI FUNCTIONS ---

clear_screen() {
    clear
    echo -e "${PURPLE}"
    echo "    ___    __              ____        __ "
    echo "   /   |  / /___ _____    / __ )____  / /_"
    echo "  / /| | / / __ \`/ __ \  / __  / __ \/ __/"
    echo " / ___ |/ / /_/ / / / / / /_/ / /_/ / /_  "
    echo "/_/  |_/_/\__,_/_/ /_/ /_____/\____/\__/  "
    echo -e "${RED}      :: SYSTEM TITAN v6.0 ::${RESET}\n"
}

check_dependencies() {
    echo -e "${YELLOW}[*] Verifying System Core...${RESET}"
    
    # 1. Curl
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: 'curl' is missing.${RESET}"
        exit 1
    fi

    # 2. XCLIP (CRITICAL FOR COPY COMMAND)
    if ! command -v xclip &> /dev/null; then
        echo -e "${YELLOW}Missing Clipboard Driver (xclip).${RESET}"
        echo -e "${CYAN}Installing xclip (Requires Sudo)...${RESET}"
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install xclip -y
        elif command -v pacman &> /dev/null; then
            sudo pacman -S xclip --noconfirm
        elif command -v dnf &> /dev/null; then
            sudo dnf install xclip -y
        else
            echo -e "${RED}Could not auto-install xclip. Please install 'xclip' manually.${RESET}"
            read -p "Press Enter to continue anyway (Copy might fail)..."
        fi
    else
        echo -e "${GREEN}✔ Clipboard Driver Active.${RESET}"
    fi

    # 3. Ollama
    if ! command -v ollama &> /dev/null; then
        echo -e "${CYAN}Installing AI Engine...${RESET}"
        curl -fsSL https://ollama.com/install.sh | sh
    fi
    
    if ! pgrep -x "ollama" > /dev/null; then
        sudo systemctl start ollama
        sleep 2
    fi
}

purge_old_models() {
    echo -e "\n${RED}${BOLD}[!] PURGING OBSOLETE NEURAL NETWORKS...${RESET}"
    for model in "${OLD_MODELS[@]}"; do
        if ollama list | grep -q "$model"; then
            echo -e "${RED}    - Deleting $model...${RESET}"
            ollama rm "$model" > /dev/null 2>&1
        fi
    done
    echo -e "${GREEN}✔ System Cleaned.${RESET}\n"
}

download_model_live() {
    local model_name="$1"
    local friendly_name="$2"
    clear_screen
    echo -e "${BOLD}${RED}⬇️  INSTALLING TITAN MODEL: ${friendly_name}${RESET}"
    echo -e "${CYAN}Target: ${model_name}${RESET}"
    ollama pull "$model_name"
    echo -e "\n${GREEN}✔ INSTALLED${RESET}"
    sleep 1
}

generate_core_files() {
    mkdir -p "$HISTORY_DIR"
    
    # 1. GENERATE PYTHON BRAIN (Updated Copy Logic)
    cat << 'PY_EOF' > "$INSTALL_DIR/alanbot.py"
import sys, os, json, re, ollama, datetime, time, random, pyperclip
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
SYS_CODER = "You are Qwen 2.5 (TITAN). You are the most advanced coding AI. Output purely functional code in Markdown blocks. Be extremely concise."
SYS_CHAT = "You are Llama 3.2 (Omni). You are a highly intelligent, conversational AI."
SYS_HYBRID = "You are Mistral-Nemo. You balance logic and creativity perfectly."

def get_omni_prompt():
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return f"You are the TITAN OMNI AI (Llama 3.2). Current System Time: {now}. You possess superior reasoning capabilities. You are aware of the current date."

def boot_sequence(model_name, mode):
    console.clear()
    steps = [
        "Initializing Titan Interface...",
        f"Mounting Model: [red]{model_name}[/red]...",
        f"Mode: [bold red]{mode.upper()}[/bold red]",
        "Linking Clipboard Drivers..."
    ]
    with console.status("[bold red]SYSTEM STARTUP...[/bold red]", spinner="bouncingBar"):
        for step in steps:
            time.sleep(0.2)
            console.print(f"[green]✔[/green] {step}")
    time.sleep(0.2)
    console.clear()

def load_config():
    default_conf = {"current_session": "default", "model": "llama3.2:latest", "mode": "internet"}
    if not os.path.exists(CONFIG_FILE): return default_conf
    try:
        with open(CONFIG_FILE, 'r') as f: return json.load(f)
    except: return default_conf

def save_history(session_name, history, model, mode):
    if not os.path.exists(HISTORY_DIR): os.makedirs(HISTORY_DIR)
    filepath = os.path.join(HISTORY_DIR, f"{session_name}.json")
    data = {"timestamp": str(datetime.datetime.now()), "model": model, "mode": mode, "history": history}
    with open(filepath, 'w') as f: json.dump(data, f, indent=4)

def load_history(session_name):
    filepath = os.path.join(HISTORY_DIR, f"{session_name}.json")
    if os.path.exists(filepath):
        try:
            with open(filepath, 'r') as f:
                data = json.load(f)
                return data["history"], data.get("model", "llama3.2:latest"), data.get("mode", "internet")
        except: return [], None, None
    return [], None, None

def clean_output(text):
    return text.replace("<```", "```").replace("```>", "```")

def main():
    config = load_config()
    session_name = config.get("current_session", "default")
    history, saved_model, saved_mode = load_history(session_name)
    
    model = saved_model if saved_model else config.get("model", "llama3.2:latest")
    mode = saved_mode if saved_mode else config.get("mode", "internet")
    
    if mode == "code": sys_prompt = SYS_CODER
    elif mode == "hybrid": sys_prompt = SYS_HYBRID
    elif mode == "internet": sys_prompt = get_omni_prompt()
    else: sys_prompt = SYS_CHAT
    
    boot_sequence(model, mode)

    header = f"🐰 ALANBOT v6.0 | Session: {session_name} | 🧠 {model}"
    console.print(Panel(header, style="bold red", border_style="red"))
    
    if history:
        console.print("[dim]Resuming conversation...[/dim]")
        for msg in history[-2:]:
            role = "YOU" if msg['role'] == 'user' else "ALANBOT"
            console.print(f"[bold]{role}:[/bold] {msg['content'][:100]}...")
    else:
        console.print("[dim]New conversation started.[/dim]")

    while True:
        try:
            user = Prompt.ask("\n[bold red]>>[/bold red]")
            
            if user.lower() in ['exit', 'quit']:
                save_history(session_name, history, model, mode)
                break
            if user.lower() == 'clear': 
                console.clear()
                continue
            if user.lower() in ['menu', 'menu-alanbot']:
                save_history(session_name, history, model, mode)
                os.system("menu-alanbot")
                sys.exit()
                
            # --- FIXED COPY COMMAND ---
            if user.lower() == 'copy':
                found = False
                for msg in reversed(history):
                    if msg['role'] == 'assistant':
                        # improved regex to catch language tagged and untagged blocks
                        codes = re.findall(r"```(?:\w+)?\n(.*?)```", msg['content'], re.DOTALL)
                        if codes:
                            try:
                                pyperclip.copy(codes[-1])
                                console.print(Panel(f"[bold green]✔ Copied to Clipboard![/bold green]\n{codes[-1][:60]}...", border_style="green"))
                                found = True
                                break
                            except Exception as e:
                                console.print(f"[bold red]Clipboard Error: {e}[/bold red]")
                                console.print("[dim]Ensure 'xclip' is installed (sudo apt install xclip)[/dim]")
                                found = True
                                break
                if not found: console.print("[red]No code blocks found.[/red]")
                continue
                
            if not user.strip(): continue

            history.append({'role': 'user', 'content': user})
            
            if mode == "internet": sys_prompt = get_omni_prompt()
            
            msgs_to_send = [{'role':'system', 'content':sys_prompt}] + history
            full_resp = ""
            
            try:
                stream = ollama.chat(model=model, messages=msgs_to_send, stream=True)
                with Live(Panel("Processing...", title="Titan AI", border_style="red"), refresh_per_second=10) as live:
                    for chunk in stream:
                        content = chunk['message']['content']
                        full_resp += content
                        live.update(Panel(Markdown(clean_output(full_resp)), title="✨ AlanBot", border_style="red"))
                
                history.append({'role': 'assistant', 'content': clean_output(full_resp)})
                save_history(session_name, history, model, mode)
            except Exception as e:
                console.print(f"[red]Error: {e}[/red]")
                break

        except KeyboardInterrupt:
            save_history(session_name, history, model, mode)
            print("\nSaved & Exiting.")
            break

if __name__ == "__main__":
    main()
PY_EOF

    # 2. GENERATE MENU
    cat << 'MENU_EOF' > "$INSTALL_DIR/menu.py"
import os, json
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.prompt import Prompt
from rich import box

CONFIG_FILE = os.path.expanduser("~/.alanbot/config.json")
HISTORY_DIR = os.path.expanduser("~/.alanbot/history")
console = Console()

def update_config(session, model, mode):
    data = {"current_session": session, "model": model, "mode": mode}
    with open(CONFIG_FILE, 'w') as f: json.dump(data, f)

def get_saved_sessions():
    if not os.path.exists(HISTORY_DIR): return []
    files = [f.replace(".json", "") for f in os.listdir(HISTORY_DIR) if f.endswith(".json")]
    return sorted(files)

def main():
    console.clear()
    console.print(Panel("🐰 ALANBOT TITAN v6.0", style="bold red", subtitle="2025 Architecture"))

    table = Table(box=box.HEAVY)
    table.add_column("Key", justify="center", style="cyan", no_wrap=True)
    table.add_column("Mode", style="bold white")
    table.add_column("Model / Brain", style="dim")
    table.add_column("Power Level", style="red")

    table.add_row("1", "INTERNET / OMNI", "Llama 3.2", "TITAN (Date + General)")
    table.add_row("2", "Titan Coder", "Qwen 2.5", "SOTA Coding Logic")
    table.add_row("3", "Titan Hybrid", "Mistral-Nemo", "Enhanced Reasoning")
    table.add_section()
    table.add_row("R", "Resume Chat", "Load Saved File", "")
    table.add_row("Q", "Exit", "", "")

    console.print(table)
    
    choice = Prompt.ask("\nSelect Option", choices=["1", "2", "3", "r", "q", "R", "Q"])
    
    if choice == "1":
        update_config(Prompt.ask("Session Name", default="omni"), "llama3.2:latest", "internet")
    elif choice == "2":
        update_config(Prompt.ask("Session Name", default="code"), "qwen2.5-coder:latest", "code")
    elif choice == "3":
        update_config(Prompt.ask("Session Name", default="hybrid"), "mistral-nemo", "hybrid")
    elif choice.lower() == "r":
        sessions = get_saved_sessions()
        if not sessions: return
        for i, s in enumerate(sessions): console.print(f"[{i+1}] {s}")
        idx = Prompt.ask("Select number", default="1")
        try: update_config(sessions[int(idx)-1], "llama3.2:latest", "internet") 
        except: return
    elif choice.lower() == "q":
        return

    os.system("alanbot")

if __name__ == "__main__":
    main()
MENU_EOF
}

do_install() {
    clear_screen
    check_dependencies
    
    # REMOVE OLD JUNK
    purge_old_models

    echo -e "${BOLD}Select Installation Type:${RESET}"
    echo "1) Install TITAN SUITE (Recommended - All 3 Models)"
    echo "2) Custom Installation"
    read -p ">> " install_type

    if [ "$install_type" == "1" ]; then
        download_model_live "$MODEL_OMNI" "TITAN OMNI (Llama 3.2)"
        download_model_live "$MODEL_CODE" "TITAN CODER (Qwen 2.5)"
        download_model_live "$MODEL_HYBRID" "TITAN HYBRID (Mistral-Nemo)"
    else
        read -p "Install TITAN OMNI (Llama 3.2)? [y/n]: " yn_omni
        [[ "$yn_omni" =~ ^[Yy]$ ]] && download_model_live "$MODEL_OMNI" "OMNI BRAIN"
        
        read -p "Install TITAN CODER (Qwen 2.5)? [y/n]: " yn_code
        [[ "$yn_code" =~ ^[Yy]$ ]] && download_model_live "$MODEL_CODE" "CODER BRAIN"
        
        read -p "Install TITAN HYBRID (Mistral-Nemo)? [y/n]: " yn_hyb
        [[ "$yn_hyb" =~ ^[Yy]$ ]] && download_model_live "$MODEL_HYBRID" "HYBRID BRAIN"
    fi

    # CONFIG
    clear_screen
    echo -e "${PURPLE}[*] Configuring Systems...${RESET}"
    if [ -d "$INSTALL_DIR/ai_env" ]; then rm -rf "$INSTALL_DIR/ai_env"; fi
    generate_core_files

    echo -e "${CYAN}Creating Virtual Environment...${RESET}"
    cd "$INSTALL_DIR"
    python3 -m venv ai_env
    source ai_env/bin/activate
    pip install --upgrade pip ollama rich pyperclip > /dev/null 2>&1

    # SYMLINKS
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

    if [ -f "$BIN_ALANBOT" ]; then sudo rm "$BIN_ALANBOT"; fi
    if [ -f "$BIN_MENU" ]; then sudo rm "$BIN_MENU"; fi
    sudo ln -s "$INSTALL_DIR/run_alanbot.sh" "$BIN_ALANBOT"
    sudo ln -s "$INSTALL_DIR/run_menu.sh" "$BIN_MENU"

    echo -e "\n${GREEN}✔ INSTALLATION COMPLETE${RESET}"
    echo -e "Type ${BOLD}menu-alanbot${RESET} to start."
}

do_uninstall() {
    rm -rf "$INSTALL_DIR"
    sudo rm "$BIN_ALANBOT" "$BIN_MENU"
    echo "Uninstalled."
}

clear_screen
echo "1) Install / Update (v6.0 TITAN)"
echo "2) Uninstall"
echo "3) Exit"
read -p ">> " choice

case $choice in
    1) do_install ;;
    2) do_uninstall ;;
    3) exit ;;
esac
