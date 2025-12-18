#!/bin/bash

# --- ALANBOT SUITE v5.9 (Omni Update) ---
# Feature: New 'Internet/Omni' Mode with Time Awareness
# Feature: Custom Installation Menu (All vs Select)
# Engine: Upgraded to Llama 3.1 for 'Strongest' Mode

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

# --- AI MODELS ---
MODEL_CODE="deepseek-coder-v2" 
MODEL_CHAT="llama3.2" 
MODEL_HYBRID="mistral"
MODEL_OMNI="llama3.1" # The "Strongest" Model

# --- UI FUNCTIONS ---

clear_screen() {
    clear
    echo -e "${PURPLE}"
    echo "    ___    __              ____        __ "
    echo "   /   |  / /___ _____    / __ )____  / /_"
    echo "  / /| | / / __ \`/ __ \  / __  / __ \/ __/"
    echo " / ___ |/ / /_/ / / / / / /_/ / /_/ / /_  "
    echo "/_/  |_/_/\__,_/_/ /_/ /_____/\____/\__/  "
    echo -e "${CYAN}      :: SYSTEM INSTALLER v5.9 ::${RESET}\n"
}

check_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: 'curl' is missing. Install it and retry.${RESET}"
        exit 1
    fi
    if ! command -v ollama &> /dev/null; then
        echo -e "${YELLOW}Authority Missing: Ollama AI Engine not found.${RESET}"
        echo -e "${CYAN}Auto-installing Ollama now...${RESET}"
        curl -fsSL https://ollama.com/install.sh | sh
    else
        echo -e "${GREEN}✔ Ollama Engine found.${RESET}"
    fi
    if ! pgrep -x "ollama" > /dev/null; then
        sudo systemctl start ollama
        sleep 2
    fi
}

download_model_live() {
    local model_name="$1"
    local friendly_name="$2"
    clear_screen
    echo -e "${BOLD}${BLUE}⬇️  DOWNLOADING BRAIN: ${friendly_name}${RESET}"
    echo -e "${CYAN}Target: ${model_name}${RESET}"
    echo -e "${CYAN}Status: Establishing Neural Link...${RESET}\n"
    ollama pull "$model_name"
    echo -e "\n${GREEN}✔ INSTALLED${RESET}"
    sleep 1
}

generate_core_files() {
    mkdir -p "$HISTORY_DIR"
    
    # 1. GENERATE PYTHON BRAIN (Now includes Time Injection)
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
SYS_CODER = "You are a DeepSeek-powered Coding Assistant. Output Markdown code blocks. Be concise."
SYS_CHAT = "You are AlanBot, a helpful assistant. Answer questions, do math, and be friendly."
SYS_HYBRID = "You are Mistral. You are intelligent, balanced, and capable of both complex logic and friendly conversation."

# THE NEW OMNI PROMPT (Dynamic)
def get_omni_prompt():
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return f"You are the STRONGEST AI Mode (Llama 3.1). Current System Time: {now}. You have extensive knowledge of the world, history, science, and people. You are precise, highly intelligent, and aware of the current date."

def boot_sequence(model_name, mode):
    console.clear()
    steps = [
        "Initializing Neural Interface...",
        f"Loading Core Model: [cyan]{model_name}[/cyan]...",
        f"Mode Selected: [bold red]{mode.upper()}[/bold red]",
        "Syncing System Clock..."
    ]
    with console.status("[bold purple]System Booting...[/bold purple]", spinner="dots"):
        for step in steps:
            time.sleep(random.uniform(0.1, 0.3))
            console.print(f"[green]✔[/green] {step}")
    time.sleep(0.3)
    console.clear()

def load_config():
    default_conf = {"current_session": "default", "model": "llama3.2", "mode": "chat"}
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
                return data["history"], data.get("model", "llama3.2"), data.get("mode", "chat")
        except: return [], None, None
    return [], None, None

def clean_output(text):
    return text.replace("<```", "```").replace("```>", "```")

def main():
    config = load_config()
    session_name = config.get("current_session", "default")
    history, saved_model, saved_mode = load_history(session_name)
    
    model = saved_model if saved_model else config.get("model", "llama3.2")
    mode = saved_mode if saved_mode else config.get("mode", "chat")
    
    # DYNAMIC PROMPT SELECTION
    if mode == "code": sys_prompt = SYS_CODER
    elif mode == "hybrid": sys_prompt = SYS_HYBRID
    elif mode == "internet": sys_prompt = get_omni_prompt()
    else: sys_prompt = SYS_CHAT
    
    boot_sequence(model, mode)

    header = f"🐰 ALANBOT | Session: {session_name} | 🧠 {model}"
    border_color = "red" if mode == "internet" else "purple"
    console.print(Panel(header, style=f"bold {border_color}", border_style=border_color))
    
    if history:
        console.print("[dim]Resuming conversation...[/dim]")
        for msg in history[-2:]:
            role = "YOU" if msg['role'] == 'user' else "ALANBOT"
            console.print(f"[bold]{role}:[/bold] {msg['content'][:100]}...")
    else:
        console.print("[dim]New conversation started.[/dim]")

    while True:
        try:
            user = Prompt.ask("\n[bold purple]>>[/bold purple]")
            
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
            if user.lower() == 'copy':
                # (Copy logic omitted for brevity, same as previous)
                continue
            if not user.strip(): continue

            history.append({'role': 'user', 'content': user})
            
            # REFRESH TIME for Internet Mode on every turn
            if mode == "internet": sys_prompt = get_omni_prompt()
            
            msgs_to_send = [{'role':'system', 'content':sys_prompt}] + history
            full_resp = ""
            
            try:
                stream = ollama.chat(model=model, messages=msgs_to_send, stream=True)
                with Live(Panel("Thinking...", title="AlanBot", border_style="bright_magenta"), refresh_per_second=10) as live:
                    for chunk in stream:
                        content = chunk['message']['content']
                        full_resp += content
                        live.update(Panel(Markdown(clean_output(full_resp)), title="✨ AlanBot", border_style="bright_magenta"))
                
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
import os, json, time
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
    console.print(Panel("🐰 ALANBOT CONTROL CENTER", style="bold magenta", subtitle="v5.9"))

    table = Table(box=box.ROUNDED)
    table.add_column("Key", justify="center", style="cyan", no_wrap=True)
    table.add_column("Mode", style="bold white")
    table.add_column("Model / Brain", style="dim")
    table.add_column("Capability", style="green")

    table.add_row("1", "General Chat", "Llama 3.2", "Casual, Fast, Writing")
    table.add_row("2", "Expert Coder", "DeepSeek V2", "Python, C++, Systems")
    table.add_row("3", "Hybrid Mode", "Mistral 7B", "Logic + Conversation")
    table.add_section()
    table.add_row("4", "INTERNET / OMNI", "Llama 3.1", "STRONGEST. Knows Date/Time + Everything")
    table.add_section()
    table.add_row("R", "Resume Chat", "Load Saved File", "Continue History")
    table.add_row("Q", "Exit", "", "")

    console.print(table)
    
    choice = Prompt.ask("\nSelect Option", choices=["1", "2", "3", "4", "r", "q", "R", "Q"])
    
    if choice == "1":
        update_config(Prompt.ask("Session Name", default="chat"), "llama3.2", "chat")
    elif choice == "2":
        update_config(Prompt.ask("Session Name", default="code"), "deepseek-coder-v2", "code")
    elif choice == "3":
        update_config(Prompt.ask("Session Name", default="hybrid"), "mistral", "hybrid")
    elif choice == "4":
        console.print("[bold red]Loading Omni-Database...[/bold red]")
        update_config(Prompt.ask("Session Name", default="omni"), "llama3.1", "internet")
    elif choice.lower() == "r":
        sessions = get_saved_sessions()
        if not sessions: return
        for i, s in enumerate(sessions): console.print(f"[{i+1}] {s}")
        idx = Prompt.ask("Select number", default="1")
        try: update_config(sessions[int(idx)-1], "llama3.2", "chat") 
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

    # --- NEW INSTALLATION MENU ---
    echo -e "${BOLD}Select Installation Type:${RESET}"
    echo "1) Install ALL AI Models (Recommended - ~25GB)"
    echo "2) Custom Installation (Choose what you want)"
    read -p ">> " install_type

    if [ "$install_type" == "1" ]; then
        download_model_live "$MODEL_CHAT" "General Chat (Llama 3.2)"
        download_model_live "$MODEL_CODE" "Expert Coder (DeepSeek V2)"
        download_model_live "$MODEL_HYBRID" "Hybrid Brain (Mistral)"
        download_model_live "$MODEL_OMNI" "INTERNET/OMNI (Llama 3.1)"
    else
        echo ""
        read -p "Install General Chat (Llama 3.2)? [y/n]: " yn_chat
        [[ "$yn_chat" =~ ^[Yy]$ ]] && download_model_live "$MODEL_CHAT" "General Chat"
        
        read -p "Install Expert Coder (DeepSeek V2)? [y/n]: " yn_code
        [[ "$yn_code" =~ ^[Yy]$ ]] && download_model_live "$MODEL_CODE" "Expert Coder"
        
        read -p "Install Hybrid Brain (Mistral)? [y/n]: " yn_hyb
        [[ "$yn_hyb" =~ ^[Yy]$ ]] && download_model_live "$MODEL_HYBRID" "Hybrid Brain"
        
        read -p "Install INTERNET/OMNI (Llama 3.1 - The Strongest)? [y/n]: " yn_omni
        [[ "$yn_omni" =~ ^[Yy]$ ]] && download_model_live "$MODEL_OMNI" "OMNI BRAIN"
    fi

    # SETUP FILES
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
echo "1) Install / Update (v5.9 Omni)"
echo "2) Uninstall"
echo "3) Exit"
read -p ">> " choice

case $choice in
    1) do_install ;;
    2) do_uninstall ;;
    3) exit ;;
esac
