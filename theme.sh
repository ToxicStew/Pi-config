#!/bin/bash

# Raspberry Pi OS Theme Customization Script
# Allows users to customize icons, colors, and fonts

# Color codes for fancy output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration files
OPENBOX_CONFIG="$HOME/.config/openbox/lxde-rc.xml"
GTK_CONFIG="$HOME/.gtkrc-2.0"
GTK3_CONFIG="$HOME/.config/gtk-3.0/settings.ini"

# Theme directories
ICON_THEME_DIR="/usr/share/icons"
GTK_THEME_DIR="/usr/share/themes"
FONT_DIR="/usr/share/fonts"

# Backup existing configuration
backup_config() {
    mkdir -p "$HOME/.theme_backup"
    cp "$OPENBOX_CONFIG" "$HOME/.theme_backup/openbox_rc.xml.bak"
    cp "$GTK_CONFIG" "$HOME/.theme_backup/gtkrc-2.0.bak"
    cp "$GTK3_CONFIG" "$HOME/.theme_backup/gtk3_settings.ini.bak"
    echo -e "${GREEN}Configurations backed up successfully!${NC}"
}

# List available icon themes
list_icon_themes() {
    echo -e "${YELLOW}Available Icon Themes:${NC}"
    ls "$ICON_THEME_DIR"
}

# List available GTK themes
list_gtk_themes() {
    echo -e "${YELLOW}Available GTK Themes:${NC}"
    ls "$GTK_THEME_DIR"
}

# List available system fonts
list_fonts() {
    echo -e "${YELLOW}Available Fonts:${NC}"
    fc-list : file | cut -d: -f2
}

# Change Icon Theme
change_icon_theme() {
    list_icon_themes
    read -p "Enter the name of the icon theme: " icon_theme
    
    # Validate theme exists
    if [ ! -d "$ICON_THEME_DIR/$icon_theme" ]; then
        echo -e "${RED}Error: Icon theme not found!${NC}"
        return 1
    fi

    # Update GTK configuration files
    sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=$icon_theme/" "$GTK_CONFIG"
    sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=$icon_theme/" "$GTK3_CONFIG"
    
    echo -e "${GREEN}Icon theme set to $icon_theme successfully!${NC}"
}

# Change GTK Theme
change_gtk_theme() {
    list_gtk_themes
    read -p "Enter the name of the GTK theme: " gtk_theme
    
    # Validate theme exists
    if [ ! -d "$GTK_THEME_DIR/$gtk_theme" ]; then
        echo -e "${RED}Error: GTK theme not found!${NC}"
        return 1
    fi

    # Update GTK configuration files
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=$gtk_theme/" "$GTK_CONFIG"
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=$gtk_theme/" "$GTK3_CONFIG"
    
    echo -e "${GREEN}GTK theme set to $gtk_theme successfully!${NC}"
}

# Change System Font
change_font() {
    list_fonts
    read -p "Enter the full path of the font you want to use: " font_path
    
    # Validate font exists
    if [ ! -f "$font_path" ]; then
        echo -e "${RED}Error: Font file not found!${NC}"
        return 1
    fi

    # Install font
    sudo cp "$font_path" "$FONT_DIR"
    sudo fc-cache -f -v

    # Update GTK configuration
    font_name=$(basename "$font_path")
    sed -i "s/gtk-font-name=.*/gtk-font-name=$font_name/" "$GTK_CONFIG"
    sed -i "s/gtk-font-name=.*/gtk-font-name=$font_name/" "$GTK3_CONFIG"
    
    echo -e "${GREEN}Font $font_name installed and set successfully!${NC}"
}

# Main menu
main_menu() {
    while true; do
        echo -e "${YELLOW}===== Raspberry Pi OS Theme Customization =====${NC}"
        echo "1. Backup Current Configuration"
        echo "2. Change Icon Theme"
        echo "3. Change GTK Theme"
        echo "4. Change System Font"
        echo "5. Exit"
        read -p "Enter your choice (1-5): " choice

        case $choice in
            1) backup_config ;;
            2) change_icon_theme ;;
            3) change_gtk_theme ;;
            4) change_font ;;
            5) exit 0 ;;
            *) echo -e "${RED}Invalid option! Please try again.${NC}" ;;
        esac

        read -p "Press Enter to continue..." # Pause before showing menu again
    done
}

# Check if script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run with sudo${NC}" 
   exit 1
fi

# Start the main menu
main_menu
