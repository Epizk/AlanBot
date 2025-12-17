#!/bin/bash

# --- ALANBOT SUITE v4.1 ---
# Features: Loading Screen, Mode Selection, and Smart Prompts.

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

# --- INSTALLER FUNCTIONS ---

loading_bar() {
    local msg="$1"
    local duration=${2:-2}
    echo -ne "\n${BOLD}${PURPLE}[*] $msg${RESET}\n"
    for ((i=0; i<=100; i+=5)); do
        printf "\r${PURPLE}[%-20s] %d%%${RESET}" "$(head -c $((i/5)) < /dev/zero | tr '\0' '█')" "$i"
        sleep $(bc <<< "scale=4; $duration / 20")
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
    echo -e "${CYAN}      :: SYSTEM INSTALLER v4.1 ::${RESET}\n"
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
from rich.layout import Layout

try: import pyperclip
except ImportError: pyperclip = None

MODEL_NAME = "deepseek-coder:6.7b"
console = Console()

# --- PROMPTS ---
PROMPT_CODING = """
You are a high-performance code generator.
RULES:
1. Output ONLY Markdown code blocks (e.g., ```python).
2. Do not explain the code. Do not chat.
3. If the user asks for a website for a specific business (e.g., "Redlinski's"), generate a professional TEMPLATE for that type of business. Do not refuse.
"""

PROMPT_CHAT = """
You are a helpful AI assistant. 
1. Answer questions clearly and concisely.
2. Explain concepts simply.
3. You can use code blocks for examples if needed.
"""

PROMPT_HYBRID = """
You are AlanBot, an expert coding companion.
1. You can chat, explain concepts, AND write code.
2. When writing code, use Markdown blocks.
3. Be helpful, concise, and smart.
"""

def clean_output(text):
    # Fix broken brackets hallucinated by some models
    text = text.replace("<```", "```").replace("```>", "```")
    return text

def show_fake_loading():
    """Shows a cool retro loading screen on startup"""
    console.clear()
    steps = ["Initializing Core...", "Connecting to DeepSeek...", "Mounting Filesystem...", "Loading Personality..."]
    
    for step in steps:
        time.sleep(random.uniform(0.3, 0.7))
        console.print(f"[bold purple]>> {step}[/bold purple]")
    
    time.sleep(0.5)
    console.clear()

def get_mode():
    """Displays the Mode Selection Menu"""
    console.print(Panel(Text("🐰 ALANBOT v4.1", justify="center", style="bold magenta"), style="purple"))
    console.print("\n[bold white]Select Operation Mode:[/bold white]")
    console.print("[1] [bold cyan]Coding Only[/bold cyan] (Strict, Fast, No Chat)")
    console.print("[2] [bold green]Questions[/bold green] (Explanations, Chat)")
    console.print("[3] [bold yellow]Hybrid[/bold yellow] (Both - Recommended)\n")
    
    while True:
        choice = Prompt.ask("[bold purple]Selection[/bold purple]", choices=["1", "2", "3"], default="3")
        if choice == "1": return PROMPT_CODING, "💻 CODING MODE"
        if choice == "2": return PROMPT_CHAT, "🗣️ CHAT MODE"
        if choice == "3": return PROMPT_HYBRID, "🚀 HYBRID MODE"

def main():
    # 1. Loading Screen
    show_fake_loading()
    
    # 2. Menu
    system_prompt, mode_name = get_mode()
    
    console.clear()
    header_text = f"🐰 ALANBOT ONLINE | {mode_name}"
    console.print(Panel(header_text, style="bold magenta", border_style="purple"))
    console.print("[dim]Type 'exit' to quit, 'copy' to copy code, 'clear' to clear.[/dim]\n")

    history = []
    
    while True:
        try:
            user = Prompt.ask("\n[bold purple]alanbot >>[/bold purple]")
            
            # Commands
            if user.lower() in ['exit', 'quit']: break
            if user.lower() == 'clear': 
                console.clear()
                console.print(Panel(header_text, style="bold magenta", border_style="purple"))
                continue
            
            if user.lower() == 'copy':
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

            # AI Logic
            history.append({'role': 'user', 'content': user})
            
            with Live(Panel("Thinking...", style="dim purple"), refresh_per_second=10) as live:
                full_resp = ""
                # Send the selected SYSTEM PROMPT first
                messages = [{'role':'system', 'content':system_prompt}] + history
                
                stream = ollama.chat(model=MODEL_NAME, messages=messages, stream=True)
                
                for chunk in stream:
                    content = chunk['message']['content']
                    full_resp += content
                    clean = clean_output(full_resp)
                    live.update(Panel(Markdown(clean), title=f"✨ AlanBot ({mode_name})", border_style="bright_magenta"))
                
                history.append({'role': 'assistant', 'content': clean_output(full_resp)})

        except KeyboardInterrupt:
            console.print("\n[purple]Shutting down...[/purple]")
            break

if __name__ == "__main__":
    main()
PY_EOF
}

do_install() {
    # CHECKS
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}Error: Install Ollama first ([https://ollama.com](https://ollama.com)).${RESET}"
        exit 1
    fi

    # MODEL
    echo -e "${CYAN}Checking Brain...${RESET}"
    if ! ollama list | grep -q "$MODEL_ID"; then
        echo "Downloading DeepSeek Model..."
        ollama pull "$MODEL_ID"
    fi

    # INSTALL
    loading_bar "Installing v4.1 Core..." 2
    rm -rf "$INSTALL_DIR"
    generate_python

    # ENV
    cd "$INSTALL_DIR"
    python3 -m venv ai_env
    source ai_env/bin/activate
    pip install ollama rich pyperclip > /dev/null 2>&1

    # GLOBAL COMMAND
    cat << LAUNCHER > "$INSTALL_DIR/launcher.sh"
#!/bin/bash
source "$INSTALL_DIR/ai_env/bin/activate"
python3 "$INSTALL_DIR/alanbot.py"
LAUNCHER
    chmod +x "$INSTALL_DIR/launcher.sh"

    if [ -f "$BIN_PATH" ]; then sudo rm "$BIN_PATH"; fi
    
    echo -e "${PURPLE}Permission needed to create 'alanbot' command:${RESET}"
    sudo ln -s "$INSTALL_DIR/launcher.sh" "$BIN_PATH"

    echo -e "\n${GREEN}✔ SUCCESS!${RESET}"
    echo -e "Type ${BOLD}alanbot${RESET} to start."
}

do_uninstall() {
    rm -rf "$INSTALL_DIR"
    sudo rm "$BIN_PATH"
    echo "Uninstalled."
}

# --- MENU ---
show_header
echo "1) Install AlanBot v4.1 (Fixes 'Dumb' AI)"
echo "2) Uninstall"
echo "3) Exit"
read -p ">> " choice

case $choice in
    1) do_install ;;
    2) do_uninstall ;;
    3) exit ;;
esac
