#!/bin/bash

# --- ALANBOT SUITE v4.0 ---
# The only file you need.
# Handles Install, Repair, Uninstall, and Global Command creation.

# --- COLORS & UI ---
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
GREY='\033[0;90m'
RESET='\033[0m'
BOLD='\033[1m'

INSTALL_DIR="$HOME/.alanbot"
BIN_PATH="/usr/local/bin/alanbot"
MODEL_ID="deepseek-coder:6.7b"

# --- LOADING BAR FUNCTION ---
# Usage: loading_bar "Message" Duration
loading_bar() {
    local msg="$1"
    local duration=${2:-2}
    local width=30
    local step=$(bc <<< "scale=4; $duration / 100")
    
    echo -ne "\n${BOLD}${PURPLE}[*] $msg${RESET}\n"
    
    for ((i=0; i<=100; i+=2)); do
        local filled=$(printf "%0.s█" $(seq 1 $((i*width/100))))
        local empty=$(printf "%0.s░" $(seq 1 $((width-(i*width/100)))))
        echo -ne "\r${PURPLE}[${filled}${GREY}${empty}${PURPLE}] ${i}%${RESET}"
        sleep $step
    done
    echo -e " ${GREEN}✔ DONE${RESET}\n"
}

# --- HEADER ART ---
show_logo() {
    clear
    echo -e "${PURPLE}"
    echo "    ___    __              ____        __ "
    echo "   /   |  / /___ _____    / __ )____  / /_"
    echo "  / /| | / / __ \`/ __ \  / __  / __ \/ __/"
    echo " / ___ |/ / /_/ / / / / / /_/ / /_/ / /_  "
    echo "/_/  |_/_/\__,_/_/ /_/ /_____/\____/\__/  "
    echo -e "${CYAN}      :: REPAIR & INSTALL SUITE v4.0 ::${RESET}\n"
}

# --- UNINSTALLER ---
do_uninstall() {
    echo -e "${RED}!!! WARNING !!!${RESET}"
    echo -e "This will completely delete AlanBot and the 'alanbot' command."
    read -p "Are you sure? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then return; fi

    loading_bar "Removing Files..." 1
    rm -rf "$INSTALL_DIR"
    
    if [ -f "$BIN_PATH" ]; then
        echo -e "${CYAN}[sudo] Removing global command...${RESET}"
        sudo rm "$BIN_PATH"
    fi
    
    echo -e "${GREEN}✔ AlanBot has been uninstalled.${RESET}"
    exit 0
}

# --- GENERATE PYTHON CORE (v3.7 Fix) ---
generate_python() {
    mkdir -p "$INSTALL_DIR"
    
    cat << 'PY_EOF' > "$INSTALL_DIR/alanbot.py"
import sys, re, ollama, platform
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel
from rich.live import Live
from rich.text import Text
from rich.align import Align
from rich.prompt import Prompt

# Clipboard setup
try: import pyperclip
except ImportError: pyperclip = None

MODEL_NAME = "deepseek-coder:6.7b"
VERSION = "v4.0 (Global)"
console = Console()

# --- THE FIX: Sanitizes broken <``` inputs ---
def clean_output(text):
    text = text.replace("<```", "```")
    text = text.replace("```>", "```")
    return text

def get_header():
    bunny = r"""
   (\_/)
   ( •_•)   ALANBOT
   / > 💜   SYSTEM ONLINE"""
    return Panel(Text(bunny, style="bold bright_magenta"), style="purple", expand=False)

def main():
    console.clear()
    console.print(get_header())
    history = []
    
    while True:
        try:
            # User Input
            user = Prompt.ask("\n[bold purple]alanbot >>[/bold purple]")
            
            # Commands
            if user.lower() in ['exit', 'quit']: break
            if user.lower() == 'clear': 
                console.clear()
                console.print(get_header())
                continue
            
            if user.lower() == 'copy':
                if not history: 
                    console.print("[red]Nothing to copy.[/red]")
                    continue
                last_msg = history[-1]['content']
                # Extract code block
                code = re.findall(r'```(?:\w+)?\s*([\s\S]*?)\s*```', last_msg)
                if code and pyperclip:
                    pyperclip.copy(code[-1].strip())
                    console.print("[bold green]✔ Copied to clipboard![/bold green]")
                elif not pyperclip:
                    console.print("[red]Error: 'pyperclip' module missing.[/red]")
                else:
                    console.print("[red]No code block found in last message.[/red]")
                continue

            if not user.strip(): continue

            # AI Processing
            history.append({'role': 'user', 'content': user})
            
            with Live(Panel("...", style="dim purple"), refresh_per_second=10) as live:
                full_resp = ""
                # STRICT PROMPT
                sys_prompt = "You are a CLI coding bot. OUTPUT ONLY MARKDOWN CODE. NO CONVERSATION."
                
                stream = ollama.chat(model=MODEL_NAME, messages=[{'role':'system', 'content':sys_prompt}] + history, stream=True)
                
                for chunk in stream:
                    content = chunk['message']['content']
                    full_resp += content
                    # Real-time sanitation
                    clean = clean_output(full_resp)
                    live.update(Panel(Markdown(clean), title="✨ AlanBot", border_style="bright_magenta"))
                
                # Save sanitized version
                history.append({'role': 'assistant', 'content': clean_output(full_resp)})

        except KeyboardInterrupt:
            break

if __name__ == "__main__":
    main()
PY_EOF
}

# --- MAIN INSTALLER LOGIC ---
do_install() {
    # 1. PRE-FLIGHT CHECKS
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Error: Python3 is not installed.${RESET}"
        exit 1
    fi

    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}Error: Ollama is missing.${RESET}"
        echo "Please install from [https://ollama.com](https://ollama.com) first."
        exit 1
    fi

    # 2. MODEL CHECK
    echo -e "${CYAN}Checking AI Engine...${RESET}"
    if ! ollama list | grep -q "$MODEL_ID"; then
        echo -e "${PURPLE}Model ($MODEL_ID) not found. Downloading...${RESET}"
        ollama pull "$MODEL_ID"
    else
        echo -e "${GREEN}✔ Model Ready.${RESET}"
    fi

    # 3. SETUP FOLDER & ENV
    loading_bar "Building Brain Logic..." 1
    
    # Nuke old folder for a clean install
    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
    
    # Generate the python file
    generate_python
    
    # Setup venv
    loading_bar "Installing Python Deps..." 2
    cd "$INSTALL_DIR"
    python3 -m venv ai_env
    source ai_env/bin/activate
    pip install ollama rich pyperclip > /dev/null 2>&1

    # 4. CREATE GLOBAL COMMAND
    echo -e "\n${CYAN}Creating global 'alanbot' command...${RESET}"
    
    # Create the launcher script locally first
    cat << LAUNCHER > "$INSTALL_DIR/launcher.sh"
#!/bin/bash
source "$INSTALL_DIR/ai_env/bin/activate"
python3 "$INSTALL_DIR/alanbot.py"
LAUNCHER
    chmod +x "$INSTALL_DIR/launcher.sh"

    # Move to /usr/local/bin (Needs sudo)
    if [ -f "$BIN_PATH" ]; then
        echo "Updating existing command..."
        sudo rm "$BIN_PATH"
    fi
    
    echo -e "${PURPLE}[sudo] Password required to make 'alanbot' command global:${RESET}"
    sudo ln -s "$INSTALL_DIR/launcher.sh" "$BIN_PATH"

    loading_bar "Finalizing Install..." 1

    echo -e "\n${GREEN}==============================${RESET}"
    echo -e "${GREEN}   ✔ INSTALLATION COMPLETE    ${RESET}"
    echo -e "${GREEN}==============================${RESET}"
    echo -e "You can now type ${BOLD}${PURPLE}alanbot${RESET} anywhere in your terminal."
}

# --- MENU ---
show_logo
echo "Select an option:"
echo "1) Install / Repair AlanBot"
echo "2) Uninstall AlanBot"
echo "3) Exit"
echo
read -p ">> " choice

case $choice in
    1) do_install ;;
    2) do_uninstall ;;
    3) exit ;;
    *) echo "Invalid option";;
esac
