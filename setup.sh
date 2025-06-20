#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

print_green() {
    echo -e "${GREEN}$1${NC}"
}

print_yellow() {
    echo -e "${YELLOW}$1${NC}"
}

print_red() {
    echo -e "${RED}$1${NC}"
}

chmod +x "$0"

if [ -d "../node_modules" ]; then
    print_green "Found node_modules in parent directory"
    MODULES_DIR=".."
else
    print_green "Using current directory for node_modules"
    MODULES_DIR="."
fi

create_default_configs() {
    cat > configs.json << EOL
{
  "timeZone": "en-US",
  "delayEachAccount": [5, 8],
  "timeToRestartAllAccounts": 300,
  "howManyAccountsRunInOneTime": 100,
  "referralCode": "aWFtYWtpZD",
  "passwordsForCreateAccounts": "123456789",
  "howManyAccountsRunInOneTimeWhenCreateAccounts": 100,
  "isSkipInvalidProxy": false,
  "rotateProxyForAllAccounts": true,
  "proxyRotationInterval": 2
}
EOL
}

check_configs() {
    if ! node -e "const cfg=require('./configs.json');if(typeof cfg.howManyAccountsRunInOneTime !== 'number' || cfg.howManyAccountsRunInOneTime < 1) throw new Error('Invalid config');" 2>/dev/null; then
        print_red "Invalid configuration detected. Resetting to default values..."
        create_default_configs
        print_green "Configuration reset completed."
    fi
}

while true; do
    clear
    echo "============================================================================"
    echo "    Pipe network BOT SETUP AND RUN SCRIPT by @MeoMunDep"
    echo "============================================================================"
    echo
    echo "Current directory: $(pwd)"
    echo "Node modules directory: $MODULES_DIR/node_modules"
    echo
    echo "1. Install/Update Node.js Dependencies"
    echo "2. Run the Bot"
    echo "3. Exit"
    echo
    read -p "Enter your choice (1-3): " choice

    case $choice in
        1)
            clear
            print_yellow "Installing/Updating Node.js dependencies..."
            cd "$MODULES_DIR"
            npm install user-agents axios colors p-limit https-proxy-agent socks-proxy-agent crypto-js ws uuid xlsx readline-sync
            cd - > /dev/null
            print_green "Dependencies installation completed!"
            read -p "Press Enter to continue..."
            ;;
        2)
            clear
            print_yellow "Checking configuration before starting..."
            if ! check_configs; then
                print_red "Error: Invalid configuration detected. Please run option 2 to fix configuration."
                read -p "Press Enter to continue..."
                continue
            fi

            print_green "Starting the bot..."
            if [ -d "../node_modules" ]; then
                print_green "Using node_modules from parent directory"
            else
                print_green "Using node_modules from current directory"
            fi
            node meomundep
            read -p "Press Enter to continue..."
            ;;
        3)
            print_green "Exiting..."
            exit 0
            ;;
        *)
            print_red "Invalid option. Please try again."
            read -p "Press Enter to continue..."
            ;;
    esac
done
