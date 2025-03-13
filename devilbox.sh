#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Welcome message
echo -e ""
echo -e "${GREEN}🌟 ${YELLOW}Welcome to Devilbox! 🌟${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "This script is located at: ${RED}$HOME/.local/bin/devilbox.sh${NC}"
echo -e "${BLUE}======================================${NC}"

# Show system info
echo -e "${BLUE}📁 Current directory: $(pwd)${NC}"
echo -e "${BLUE}💻 User: $(whoami)${NC}"
echo -e ""

# Request sudo at the start
sudo -v

DEVILBOX_PATH="/mnt/data/devilbox"  # Path to Devilbox directory
CONTAINER_NAME="devilbox-php-1"     # PHP container name

# Function: Get project path dynamically
function get_project_path() {
    local original_path="$1"
    local project_name

    # Extract the last folder name (project name)
    project_name=$(basename "$original_path")

    # Build the container path
    echo "/shared/httpd/$project_name"
}

# Save current path
ORIGINAL_PATH=$(pwd)
PROJECT_PATH=$(get_project_path "$ORIGINAL_PATH")

cd "$DEVILBOX_PATH"

case "$1" in
    start)
        echo -e "${YELLOW}🚀 Starting Devilbox...${NC}"
        sudo docker-compose up -d
        ;;
    stop)
        echo -e "${YELLOW}🛑 Stopping Devilbox...${NC}"
        sudo docker-compose down
        ;;
    restart)
        echo -e "${YELLOW}🔄 Restarting Devilbox PHP container...${NC}"
        sudo docker stop $CONTAINER_NAME
        echo -e "${YELLOW}⏸️ PHP container stopped...${NC}"

        sudo docker start $CONTAINER_NAME
        echo -e "${YELLOW}▶️ PHP container started...${NC}"
        ;;
    status)
        echo -e "${YELLOW}📊 Checking Devilbox status...${NC}"
        sudo docker-compose ps
        ;;
    shell)
        echo -e "${YELLOW}💻 Entering Devilbox shell...${NC}"
        sudo ./shell.sh
        ;;
    composer)
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Please specify a Composer command.${NC}"
            echo -e "${YELLOW}Example: devilbox.sh composer require vlucas/phpdotenv${NC}"
            exit 1
        fi

        echo -e "${YELLOW}🚀 Running Composer command: ${GREEN}composer ${*:2}${NC}"
        echo -e "${BLUE}📁 Project path inside container: ${PROJECT_PATH}${NC}"
        sudo docker exec -it $CONTAINER_NAME sh -c "cd $PROJECT_PATH && composer ${*:2}"
        ;;
    .)
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Please specify a shell command.${NC}"
            echo -e "${YELLOW}Example: devilbox.sh . ls${NC}"
            exit 1
        fi

        echo -e "${YELLOW}🚀 Running shell command: ${GREEN}${*:2}${NC}"
        echo -e "${BLUE}📁 Project path inside container: ${PROJECT_PATH}${NC}"
        sudo docker exec -it $CONTAINER_NAME sh -c "cd $PROJECT_PATH && ${*:2}"
        ;;
    *)
        echo -e "${RED}❌ Invalid command.${NC}"
        echo -e "${YELLOW}Usage: devilbox.sh {start|stop|restart|status|shell|composer <command>} ${NC}"
        exit 1
        ;;
esac

# Return to the original path after execution
cd "$ORIGINAL_PATH"

echo -e ""
echo -e "${BLUE}💻 Returned to ${ORIGINAL_PATH} ${NC}"
echo -e ""
