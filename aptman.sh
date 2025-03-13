#!/bin/bash

# Check if yay is installed
if command -v yay &>/dev/null; then
    USE_YAY=true
else
    USE_YAY=false
fi

# Define colors
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
NC="\e[0m" # No Color

# Welcome message
echo -e "${GREEN}🌟 ${YELLOW}Welcome to aptman! 🌟${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "This script is located at: ${RED}$HOME/.local/bin/aptman${NC}"
echo -e "${BLUE}======================================${NC}"

# Show system info
echo -e "${BLUE}📁 Current directory: $(pwd)${NC}"
echo -e "${BLUE}💻 User: $(whoami)${NC}"
echo -e ""

# Request sudo upfront
sudo -v

# Command handler
case "$1" in
    update)
        echo -e "🔄 ${YELLOW}Updating package database...${NC}"
        sudo pacman -Sy
        ;;
    upgrade)
        if [ "$USE_YAY" = true ]; then
            echo -e "⬆️ ${GREEN}Upgrading all packages (including AUR)...${NC}"
            yay -Syu
        else
            echo -e "⬆️ ${GREEN}Upgrading official packages...${NC}"
            sudo pacman -Syu
        fi
        ;;
    install)
        shift
        if [ "$USE_YAY" = true ]; then
            echo -e "📦 ${BLUE}Installing package(s) (official & AUR): $@${NC}"
            yay -S "$@"
        else
            echo -e "📦 ${BLUE}Installing package(s) (official repo only): $@${NC}"
            sudo pacman -S "$@"
        fi
        ;;
    remove)
        shift
        echo -e "🗑️ ${RED}Removing package(s): $@${NC}"
        sudo pacman -R "$@"
        ;;
    autoremove)
        echo -e "🧹 ${YELLOW}Removing orphaned packages...${NC}"
        sudo pacman -Rns $(pacman -Qdtq)
        ;;
    search)
        shift
        if [ "$USE_YAY" = true ]; then
            echo -e "🔍 ${GREEN}Searching for package (official & AUR): $@${NC}"
            yay -Ss "$@"
        else
            echo -e "🔍 ${GREEN}Searching for package (official repo only): $@${NC}"
            pacman -Ss "$@"
        fi
        ;;
    info)
        shift
        echo -e "ℹ️ ${BLUE}Showing info for package: $@${NC}"
        pacman -Qi "$@"
        ;;
    list)
        echo -e "📋 ${YELLOW}Listing explicitly installed packages...${NC}"
        pacman -Qe
        ;;
    clean)
        echo -e "🧽 ${GREEN}Cleaning old package cache...${NC}"
        sudo pacman -Sc
        ;;
    fullclean)
        echo -e "💣 ${RED}Removing all cached packages...${NC}"
        sudo pacman -Scc
        ;;
    deps)
        echo -e "🔗 ${YELLOW}Checking for orphaned dependencies...${NC}"
        pacman -Qdt
        ;;
    files)
        shift
        echo -e "📂 ${BLUE}Listing files of package: $@${NC}"
        pacman -Ql "$@"
        ;;
    find)
        shift
        echo -e "🔎 ${GREEN}Finding package containing: $@${NC}"
        pacman -Fs "$@"
        ;;
    ownedby)
        shift
        echo -e "🏷️ ${YELLOW}Finding package that owns: $@${NC}"
        pacman -Qo "$@"
        ;;
    *)
        echo -e "❓ ${RED}Invalid command!${NC}"
        echo -e "Usage: aptman {update|upgrade|install|remove|autoremove|search|info|list|clean|fullclean|deps|files|find|ownedby} [package]"
        exit 1
        ;;
esac
