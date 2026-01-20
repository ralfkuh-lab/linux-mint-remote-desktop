#!/bin/bash
#
# setup-xrdp.sh - Automatisches Setup für xrdp auf Linux Mint (Cinnamon)
#
# Dieses Script installiert und konfiguriert xrdp für Remote Desktop Zugriff
# auf Linux Mint mit Cinnamon Desktop-Umgebung.
#
# Verwendung: ./setup-xrdp.sh
#
# Autor: Ralf
# Lizenz: MIT
# Repository: https://github.com/ralfkuh-lab/linux-mint-remote-desktop
#

set -e

# Farben für Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funktionen für formatierte Ausgabe
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNUNG]${NC} $1"
}

error() {
    echo -e "${RED}[FEHLER]${NC} $1"
    exit 1
}

# Banner anzeigen
echo ""
echo "=============================================="
echo "  Linux Mint xrdp Setup Script"
echo "  Remote Desktop für Cinnamon Desktop"
echo "=============================================="
echo ""

# Root/Sudo-Prüfung
if [[ $EUID -eq 0 ]]; then
    error "Bitte führen Sie dieses Script NICHT als root aus. Verwenden Sie stattdessen einen normalen Benutzer mit sudo-Rechten."
fi

if ! sudo -v; then
    error "Sudo-Rechte erforderlich. Bitte stellen Sie sicher, dass Ihr Benutzer sudo-Berechtigung hat."
fi

info "Sudo-Rechte verifiziert."

# Linux Mint Version erkennen und prüfen
if [[ -f /etc/linuxmint/info ]]; then
    MINT_VERSION=$(grep "^RELEASE=" /etc/linuxmint/info | cut -d'=' -f2)
    info "Erkannte Linux Mint Version: ${MINT_VERSION}"

    # Prüfe ob Version 21.x oder 22.x
    if [[ ! "${MINT_VERSION}" =~ ^(21|22)\. ]]; then
        warning "Dieses Script wurde für Linux Mint 21.x und 22.x getestet."
        warning "Ihre Version (${MINT_VERSION}) könnte funktionieren, ist aber nicht offiziell unterstützt."
    fi
else
    warning "Konnte Linux Mint Version nicht ermitteln. Fahre trotzdem fort..."
fi

# Desktop-Umgebung prüfen
if [[ "${XDG_CURRENT_DESKTOP}" == *"Cinnamon"* ]] || [[ -n "$(pgrep -x cinnamon)" ]]; then
    info "Cinnamon Desktop erkannt."
else
    warning "Cinnamon Desktop nicht erkannt. Dieses Script ist für Cinnamon optimiert."
fi

# Prüfen ob xrdp bereits installiert ist
if dpkg -l | grep -q "^ii  xrdp "; then
    XRDP_INSTALLED=true
    CURRENT_VERSION=$(dpkg -l | grep "^ii  xrdp " | awk '{print $3}')
    warning "xrdp ist bereits installiert (Version: ${CURRENT_VERSION})."
    echo ""
    read -p "Möchten Sie die Konfiguration trotzdem aktualisieren? (j/N): " CONFIRM_UPDATE
    if [[ ! "${CONFIRM_UPDATE}" =~ ^[jJyY]$ ]]; then
        info "Abbruch durch Benutzer."
        exit 0
    fi
else
    XRDP_INSTALLED=false
fi

# Benutzerbestätigung vor Installation
echo ""
echo "Folgende Aktionen werden durchgeführt:"
echo "  1. System-Paketliste aktualisieren"
if [[ "${XRDP_INSTALLED}" == false ]]; then
    echo "  2. xrdp und xorgxrdp installieren"
fi
echo "  3. Polkit-Regel für Cinnamon erstellen"
echo "  4. xrdp-Dienst aktivieren und starten"
echo ""
read -p "Möchten Sie fortfahren? (j/N): " CONFIRM
if [[ ! "${CONFIRM}" =~ ^[jJyY]$ ]]; then
    info "Installation abgebrochen."
    exit 0
fi

echo ""
info "Starte Installation..."
echo ""

# System aktualisieren
info "Aktualisiere Paketliste..."
sudo apt update
success "Paketliste aktualisiert."

# xrdp und Abhängigkeiten installieren
if [[ "${XRDP_INSTALLED}" == false ]]; then
    info "Installiere xrdp und xorgxrdp..."
    sudo apt install xrdp xorgxrdp -y
    success "xrdp und xorgxrdp installiert."
else
    info "xrdp bereits installiert, überspringe Paketinstallation."
fi

# Polkit-Regel für Cinnamon erstellen (colord-Berechtigungen)
info "Erstelle Polkit-Regel für Cinnamon..."
POLKIT_FILE="/etc/polkit-1/rules.d/45-allow-colord.rules"

sudo tee "${POLKIT_FILE}" > /dev/null << 'EOF'
// Erlaubt colord-Aktionen für lokale aktive Sitzungen (xrdp)
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.color-manager.") == 0) {
        return polkit.Result.YES;
    }
});
EOF

success "Polkit-Regel erstellt: ${POLKIT_FILE}"

# xrdp-Dienst aktivieren und starten
info "Aktiviere xrdp-Dienst..."
sudo systemctl enable xrdp
success "xrdp-Dienst aktiviert (startet automatisch beim Booten)."

info "Starte xrdp-Dienst neu..."
sudo systemctl restart xrdp
success "xrdp-Dienst gestartet."

# Status prüfen
info "Prüfe xrdp-Status..."
if systemctl is-active --quiet xrdp; then
    success "xrdp läuft erfolgreich!"
else
    error "xrdp konnte nicht gestartet werden. Bitte prüfen Sie: sudo systemctl status xrdp"
fi

# IP-Adresse ermitteln
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Abschlussmeldung
echo ""
echo "=============================================="
echo -e "${GREEN}  Installation erfolgreich abgeschlossen!${NC}"
echo "=============================================="
echo ""
echo "Verbindungsdaten:"
echo "  IP-Adresse: ${IP_ADDRESS}"
echo "  Port:       3389 (Standard-RDP-Port)"
echo ""
echo "Verbindung von Windows herstellen:"
echo "  1. Win+R drücken"
echo "  2. 'mstsc' eingeben und Enter drücken"
echo "  3. IP-Adresse eingeben: ${IP_ADDRESS}"
echo "  4. Mit Ihrem Linux-Benutzernamen und Passwort anmelden"
echo ""
echo "Hinweis: Falls Sie lokal angemeldet sind, melden Sie sich"
echo "         dort ab, bevor Sie sich remote verbinden."
echo ""
