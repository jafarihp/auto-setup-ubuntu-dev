#!/bin/bash

echo "🚀 Starting Ubuntu setup for frontend development..."

# 🧠 Ensure graphical environment for GNOME settings
if ! command -v dbus-launch >/dev/null 2>&1; then
    echo "⚠️ dbus-launch not found. Installing dbus-x11 for GNOME settings compatibility..."
    sudo apt install -y dbus-x11
fi

# Function to safely run gsettings if GUI is detected
run_gsettings() {
    if [ -n "$DISPLAY" ] && [ -n "$XDG_CURRENT_DESKTOP" ]; then
        gsettings "$@"
    else
        echo "⚠️ Skipping gsettings: Not running in a graphical session."
    fi
}

# Function to install or upgrade packages
install_or_upgrade() {
    local pkg=$1
    echo "🔍 Checking installation or upgrade of $pkg ..."
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "🔄 $pkg is already installed. Checking for upgrade..."
        sudo apt install --only-upgrade -y "$pkg" && echo "✅ $pkg upgraded." || echo "❌ $pkg upgrade failed (connection or install issue)"
    else
        echo "⬇️ $pkg is not installed. Installing..."
        sudo apt install -y "$pkg" && echo "✅ $pkg installed successfully." || echo "❌ $pkg installation failed (connection or install issue)"
    fi
}

# Update repositories
sudo apt update

# Check if snap is installed
if ! command -v snap >/dev/null 2>&1; then
    echo "📦 Snap is not installed. Installing snapd..."
    sudo apt update
    sudo apt install -y snapd
fi

# Install Google Chrome
if ! command -v google-chrome >/dev/null 2>&1; then
    echo "🌐 Installing Google Chrome..."
    wget --timeout=180 -q -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && sudo apt install -y ./chrome.deb && echo "✅ Google Chrome installed." || echo "❌ Google Chrome installation failed."
    rm -f chrome.deb
else
    echo "🔄 Updating Google Chrome..."
    sudo apt install --only-upgrade -y google-chrome-stable && echo "✅ Google Chrome upgraded." || echo "❌ Google Chrome upgrade failed."
fi

# Install VS Code
if ! command -v code >/dev/null 2>&1; then
    echo "🧠 Installing VS Code..."
    wget --timeout=180 -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo apt update
    sudo apt install -y code && echo "✅ VS Code installed." || echo "❌ VS Code installation failed."
else
    echo "🔄 Updating VS Code..."
    sudo apt install --only-upgrade -y code && echo "✅ VS Code upgraded." || echo "❌ VS Code upgrade failed."
fi

# VS Code extension: Code Spell Checker
if ! code --list-extensions | grep -q 'streetsidesoftware.code-spell-checker'; then
    echo "🔤 Installing VS Code extension: Code Spell Checker..."
    code --install-extension streetsidesoftware.code-spell-checker
else
    echo "✅ Code Spell Checker extension already installed."
fi

# Install Telegram via Snap (Manual method)
if ! command -v telegram-desktop >/dev/null 2>&1; then
    echo "⬇️ Installing Telegram Desktop via Snap (manual method)..."

    if ! command -v snap >/dev/null 2>&1; then
        echo "📦 Snap is not installed. Installing snapd..."
        sudo apt update
        sudo apt install -y snapd
    fi

    echo "📥 Downloading Telegram snap package..."
    snap download telegram-desktop &&
        sudo snap ack telegram-desktop_*.assert &&
        sudo snap install telegram-desktop_*.snap &&
        echo "✅ Telegram Desktop installed manually via Snap." ||
        echo "❌ Telegram installation (manual snap method) failed."

    rm -f telegram-desktop_*.snap telegram-desktop_*.assert
else
    echo "✅ Telegram Desktop is already installed."
fi

# Install RustDesk
if ! command -v rustdesk >/dev/null 2>&1; then
    echo "🧷 Installing RustDesk..."
    wget --timeout=180 -q https://github.com/rustdesk/rustdesk/releases/download/1.4.0/rustdesk-1.4.0-x86_64.deb -O rustdesk.deb && sudo apt install -y ./rustdesk.deb && echo "✅ RustDesk installed." || echo "❌ RustDesk installation failed."
    rm -f rustdesk.deb
else
    echo "✅ RustDesk already installed."
fi

# Install or upgrade packages
install_or_upgrade vlc
install_or_upgrade git
install_or_upgrade docker.io
install_or_upgrade python3-pip
install_or_upgrade simplescreenrecorder
install_or_upgrade safeeyes

# System personalization
echo "⚙️ Applying system settings..."

# Set system locale
echo "🌍 Setting system locale to en_US.UTF-8..."
sudo update-locale LANG=en_US.UTF-8

# Add Persian input source
echo "⌨️ Adding Persian input source..."
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ir')]"

# Set timezone
echo "🕒 Setting timezone to Asia/Tehran..."
sudo timedatectl set-timezone Asia/Tehran

# Set Chrome as default browser
echo "🌐 Setting Google Chrome as default browser..."
xdg-settings set default-web-browser google-chrome.desktop

# Open apps maximized
echo "🪟 Enabling window auto-maximize..."
gsettings set org.gnome.mutter auto-maximize true

# Automatic screen lock
echo "🖥️ Energy settings and screen security..."
# Display turns off after 3 minutes (180 seconds)
run_gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 180
run_gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
# Screen locks after 5 minutes of inactivity
run_gsettings set org.gnome.desktop.session idle-delay 300
run_gsettings set org.gnome.desktop.screensaver lock-delay 0
run_gsettings set org.gnome.desktop.screensaver lock-enabled true

# Set thousands separator in Calculator
echo "🧮 Enabling thousands separator in Calculator..."
gsettings set org.gnome.calculator number-format "thousands"

# Pin favorite apps to dock
echo "📌 Pinning favorite apps to dock..."
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'google-chrome.desktop', 'code.desktop', 'org.gnome.Terminal.desktop']"
