#!/bin/bash

# Check if paru or yay is installed
if command -v paru &>/dev/null; then
    PKG_MANAGER="paru"  # Paru replace Pacman + Yay complete
    AUR_HELPER=""
elif command -v yay &>/dev/null; then
    PKG_MANAGER="pacman"
    AUR_HELPER="yay"
else
    PKG_MANAGER="pacman"
    AUR_HELPER=""
fi

# Define colors
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
NC="\e[0m" # No Color

# Welcome message
# Welcome message
echo -e "${GREEN}🌟 ${YELLOW}Welcome to aptman! 🌟${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "This script is located at: ${RED}$HOME/.local/bin/aptman${NC}"
echo -e "Currently using ${PKG_MANAGER} as the package manager."
if [ -n "$AUR_HELPER" ]; then
    echo -e "AUR packages will be managed using: ${AUR_HELPER}"
fi
echo -e "${BLUE}======================================${NC}"

# Show system info
echo -e "${BLUE}📁 Current directory: $(pwd)${NC}"
echo -e "${BLUE}💻 User: $(whoami)${NC}"
echo -e ""

# Request sudo upfront (only for commands that need it)
case "$1" in
    update)
        echo -e "🔄 ${YELLOW}Updating package database...${NC}"
        sudo "$PKG_MANAGER" -Sy
        ;;
    upgrade)
        echo -e "⬆️ ${GREEN}Upgrading all packages...${NC}"
        if [ -n "$AUR_HELPER" ]; then
            "$AUR_HELPER" -Syu 
        else
            "$PKG_MANAGER" -Syu
        fi
        ;;
    install)
        shift
        if [ -n "$AUR_HELPER" ]; then
            echo -e "📦 ${BLUE}Installing package(s) (official & AUR): $@${NC}"
            "$AUR_HELPER" -S "$@"
        else
            echo -e "📦 ${BLUE}Installing package(s) (official repo only): $@${NC}"
            sudo "$PKG_MANAGER" -S "$@"
        fi
        ;;
    remove)
        shift
        echo -e "🗑️ ${RED}Removing package(s): $@${NC}"
        sudo "$PKG_MANAGER" -R "$@"
        ;;
    autoremove)
        echo -e "🧹 ${YELLOW}Removing orphaned packages...${NC}"
        sudo "$PKG_MANAGER" -Rns $(pacman -Qdtq)
        ;;
    search)
        shift
        if [ -n "$AUR_HELPER" ]; then
            echo -e "🔍 ${GREEN}Searching for package (official & AUR): $@${NC}"
            "$AUR_HELPER" -Ss "$@"
        else
            echo -e "🔍 ${GREEN}Searching for package (official repo only): $@${NC}"
            "$PKG_MANAGER" -Ss "$@"
        fi
        ;;
    info)
        shift
        echo -e "ℹ️ ${BLUE}Showing info for package: $@${NC}"
        "$PKG_MANAGER" -Qi "$@"
        ;;
    list)
        echo -e "📋 ${YELLOW}Listing explicitly installed packages...${NC}"
        "$PKG_MANAGER" -Qe
        ;;
    clean)
        echo -e "🧽 ${GREEN}Cleaning old package cache...${NC}"
        sudo "$PKG_MANAGER" -Sc
        ;;
    fullclean)
        echo -e "💣 ${RED}Removing all cached packages...${NC}"
        sudo "$PKG_MANAGER" -Scc
        ;;
    deps)
        echo -e "🔗 ${YELLOW}Checking for orphaned dependencies...${NC}"
        "$PKG_MANAGER" -Qdt
        ;;
    files)
        shift
        echo -e "📂 ${BLUE}Listing files of package: $@${NC}"
        "$PKG_MANAGER" -Ql "$@"
        ;;
    find)
        shift
        echo -e "🔎 ${GREEN}Finding package containing: $@${NC}"
        "$PKG_MANAGER" -Fs "$@"
        ;;
    ownedby)
        shift
        echo -e "🏷️ ${YELLOW}Finding package that owns: $@${NC}"
        "$PKG_MANAGER" -Qo "$@"
        ;;
    *)
        echo -e "❓ ${RED}Invalid command!${NC}"
        echo -e "Usage: aptman {update|upgrade|install|remove|autoremove|search|info|list|clean|fullclean|deps|files|find|ownedby} [package]"
        exit 1
        ;;
esac
