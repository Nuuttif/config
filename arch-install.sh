#!/bin/bash
# Arch + Hyprland MacBook 2019 Setup Script
# Installs packages and enables services, logs failures, keeps full terminal output

ERRORS=()
LOGFILE="install_errors.log"
echo "Install started at $(date)" > "$LOGFILE"

# --- Package Installation ---
echo "Installing packages..."
PACKAGES=$(grep -v '^#' packages.txt | grep -v '^\s*$')

for pkg in $PACKAGES; do
    echo "Installing $pkg..."
    if sudo pacman -S --needed --noconfirm "$pkg"; then
        echo "[OK] $pkg installed successfully"
    else
        echo "[ERROR] Failed to install $pkg" | tee -a "$LOGFILE"
        ERRORS+=("Package: $pkg")
    fi
done

# --- Enable Services ---
echo "Enabling services..."
SERVICES=(
    tlp
    thermald
    power-profiles-daemon
    NetworkManager
    bluetooth
    seatd
)

for svc in "${SERVICES[@]}"; do
    echo "Enabling $svc..."
    if sudo systemctl enable --now "$svc"; then
        echo "[OK] $svc enabled"
    else
        echo "[ERROR] Failed to enable $svc" | tee -a "$LOGFILE"
        ERRORS+=("Service: $svc")
    fi
done

# --- Refresh Font Cache ---
echo "Refreshing font cache..."
if fc-cache -fv; then
    echo "[OK] Font cache refreshed"
else
    echo "[ERROR] Font cache refresh failed" | tee -a "$LOGFILE"
    ERRORS+=("Font cache refresh")
fi

# --- Summary ---
echo
echo "================ INSTALLATION SUMMARY ================"
if [ ${#ERRORS[@]} -eq 0 ]; then
    echo "All packages and services installed successfully!"
else
    echo "The following items failed:"
    for err in "${ERRORS[@]}"; do
        echo " - $err"
    done
    echo
    echo "See $LOGFILE for more details."
fi

echo "Install finished at $(date)"
