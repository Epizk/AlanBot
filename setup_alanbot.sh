#!/bin/bash

# --- ALANBOT SUITE v4.2 ---
# Fixes: "Robot Brain" (It now understands context and won't code for simple math)

# --- COLORS & UI ---
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
BOLD='\033[1m'
RESET='\033[0m'

INSTALL_DIR="$HOME/.alanbot"
BIN_PATH="/usr/local/bin/alanbot"
MODEL_ID="deepseek-coder:6.7b"

# --- INSTALLER FUNCTIONS ---

loading_bar() {
    local msg="$1"
    local duration=${2:-2}
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
    echo -e "${CYAN}      :: SYSTEM INSTALLER v4.2 ::${RESET}\n"
}

generate_python() {
    mkdir -p "$INSTALL_DIR"
    
    # WRITING THE PYTHON BRAIN
    cat << 'PY_EOF' > "$INSTALL_DIR/alanbot.py"
import sys, re, ollama, time, random
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel
from rich.live import Live
from rich.text import Text
from rich.align import Align
from rich.prompt import Prompt

try: import pyperclip
except ImportError: pyperclip = None

MODEL_NAME = "deepseek-coder:6.7b"
console = Console()

# --- BRAIN SETTINGS (v4.2) ---
# We force the AI to be socially aware here.

PROMPT_CODING = """
ROLE: Pure Code Generator.
RULES:
1. NO CHAT. NO EXPLANATIONS.
2. Output ONLY Markdown code blocks.
"""

PROMPT_CHAT = """
ROLE: General Assistant.
RULES:
1. Do not generate code unless explicitly asked.
2. Answer simple questions directly (e.g. "4+4 is 8").
3. Be friendly and conversational.
"""

PROMPT_HYBRID = """
ROLE: AlanBot (Smart Mode).
CRITICAL INSTRUCTIONS:
1. **CONTEXT AWARENESS:** If the user asks a simple question (e.g., "What is 4+4?", "Hi", "Who are you?"), ANSWER NORMALLY. Do NOT write a Python script for this.
2. **CODING:** Only generate code if the user specifically asks for it (e.g., "Write a script", "How do I code this?").
3. **WEBSITES:** If asked for a website for a business (e.g., "Redlinski's"), create a generic HTML/CSS template. Do not refuse.
"""

def clean_output(text):
    text = text.replace("<```", "```").replace("```>", "```")
    return text

def show_fake_loading():
    console.clear()
    steps = ["Initializing Brain...", "Loading Context Awareness...", "Suppressing Robot Logic...", "System Ready."]
    for step in steps:
        time.sleep(0.3)
        console.print(f"[bold purple]>> {step}[/bold purple]")
    time.sleep(0.5)
    console.clear()

def get_mode():
    console.print(Panel(Text("🐰 ALANBOT v4.2", justify="center", style="bold magenta"), style="purple"))
    console.print("\n[bold white]Select Logic Core:[/bold white]")
    console.print("[1] [bold cyan]Code Generator[/bold cyan] (No talking, just code)")
    console.print("[2] [bold green]Chat Bot[/bold green] (Normal conversation)")
    console.print("[3] [bold yellow]Smart Hybrid[/bold yellow] (The Fixed Version)\n")
    
    while True:
        choice = Prompt.ask("[bold purple]Selection[/bold purple]", choices=["1", "2", "3"], default="3")
        if choice == "1": return PROMPT_CODING, "💻 CODE ONLY"
        if choice == "2": return PROMPT_CHAT, "🗣️ CHAT ONLY"
        if choice == "3": return PROMPT_HYBRID, "🧠 SMART HYBRID"

def main():
    show_fake_loading()
    system_prompt, mode_name = get_mode()
    
    console.clear()
    console.print(Panel(f"🐰 ALANBOT ONLINE | {mode_name}", style="bold magenta", border_style="purple"))
    
    history = []
    
    while True:
        try:
            user = Prompt.ask("\n[bold purple]alanbot >>[/bold purple]")
            
            if user.lower() in ['exit', 'quit']: break
            if user.lower() == 'clear': 
                console.clear()
                console.print(Panel(f"🐰 ALANBOT ONLINE | {mode_name}", style="bold magenta", border_style="purple"))
                continue
            
            # Copy command
            if user.lower() == 'copy':
                # (Copy logic remains the same)
                if not history: 
                    console.print("[red]Nothing to copy.[/red]")
                    continue
                last_msg = history[-1]['content']
                code = re.findall(r'```(?:\w+)?\s*([\s\S]*?)\s*```', last_msg)
                if code and pyperclip:
                    pyperclip.copy(code[-1].strip())
                    console.print("[bold green]✔ Copied![/bold green]")
                elif not pyperclip:
                    console.print("[red]Error: 'pyperclip' missing.[/red]")
                else:
                    console.print("[red]No code found.[/red]")
                continue

            if not user.strip(): continue

            history.append({'role': 'user', 'content': user})
            
            with Live(Panel("Thinking...", style="dim purple"), refresh_per_second=10) as live:
                full_resp = ""
                # We send the System Prompt EVERY time to enforce rules
                messages = [{'role':'system', 'content':system_prompt}] + history
                
                stream = ollama.chat(model=MODEL_NAME, messages=messages, stream=True)
                
                for chunk in stream:
                    content = chunk['message']['content']
                    full_resp += content
                    clean = clean_output(full_resp)
                    live.update(Panel(Markdown(clean), title=f"✨ AlanBot", border_style="bright_magenta"))
                
                history.append({'role': 'assistant', 'content': clean_output(full_resp)})

        except KeyboardInterrupt:
            break

if __name__ == "__main__":
    main()
PY_EOF
}

do_install() {
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}Error: Install Ollama first.${RESET}"
        exit 1
    fi

    # MODEL CHECK
    if ! ollama list | grep -q "$MODEL_ID"; then
        echo "Downloading DeepSeek..."
        ollama pull "$MODEL_ID"
    fi

    loading_bar "Installing v4.2 Logic..." 2
    rm -rf "$INSTALL_DIR"
    generate_python

    # ENV SETUP
    cd "$INSTALL_DIR"
    python3 -m venv ai_env
    source ai_env/bin/activate
    pip install ollama rich pyperclip > /dev/null 2>&1

    # GLOBAL LINK
    cat << LAUNCHER > "$INSTALL_DIR/launcher.sh"
#!/bin/bash
source "$INSTALL_DIR/ai_env/bin/activate"
python3 "$INSTALL_DIR/alanbot.py"
LAUNCHER
    chmod +x "$INSTALL_DIR/launcher.sh"

    if [ -f "$BIN_PATH" ]; then sudo rm "$BIN_PATH"; fi
    
    echo -e "${PURPLE}[sudo] Creating global command...${RESET}"
    sudo ln -s "$INSTALL_DIR/launcher.sh" "$BIN_PATH"

    echo -e "\n${GREEN}✔ UPGRADE COMPLETE${RESET}"
    echo -e "Run: ${BOLD}alanbot${RESET}"
}

do_uninstall() {
    rm -rf "$INSTALL_DIR"
    sudo rm "$BIN_PATH"
    echo "Uninstalled."
}

# --- MENU ---
show_header
echo "1) Install / Repair (v4.2)"
echo "2) Uninstall"
echo "3) Exit"
read -p ">> " choice

case $choice in
    1) do_install ;;
    2) do_uninstall ;;
    3) exit ;;
esac
