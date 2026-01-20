# Linux Mint Remote Desktop (xrdp)

Automatisiertes Setup-Script für Remote Desktop Zugriff auf Linux Mint mit Cinnamon Desktop via xrdp. Ermöglicht die Verbindung von Windows-Rechnern mittels der integrierten Remote Desktop Verbindung (mstsc.exe).

## Systemvoraussetzungen

### Linux Mint (Server)
- Linux Mint 21.x oder 22.x
- Cinnamon Desktop-Umgebung
- Sudo-Rechte für die Installation
- Netzwerkverbindung

### Windows (Client)
- Windows 10/11
- Remote Desktop Verbindung (mstsc.exe) - standardmäßig installiert

## Schnellstart

### Automatische Installation (empfohlen)

```bash
# Repository klonen
git clone https://github.com/ralfkuh-lab/linux-mint-remote-desktop.git
cd linux-mint-remote-desktop

# Script ausführbar machen und starten
chmod +x setup-xrdp.sh
./setup-xrdp.sh
```

### Manuelle Installation

Falls Sie das Script nicht verwenden möchten, können Sie xrdp auch manuell installieren:

```bash
# System aktualisieren und Pakete installieren
sudo apt update
sudo apt install xrdp xorgxrdp -y

# Polkit-Regel erstellen (verhindert Authentifizierungsdialog)
sudo tee /etc/polkit-1/rules.d/45-allow-colord.rules > /dev/null << 'EOF'
// Erlaubt colord-Aktionen für lokale aktive Sitzungen (xrdp)
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.color-manager.") == 0) {
        return polkit.Result.YES;
    }
});
EOF

# xrdp-Dienst aktivieren und starten
sudo systemctl enable xrdp
sudo systemctl start xrdp

# IP-Adresse anzeigen
hostname -I | awk '{print $1}'
```

## Verbindung von Windows herstellen

1. **Remote Desktop öffnen:**
   - Drücken Sie `Win + R`
   - Geben Sie `mstsc` ein und drücken Sie Enter

2. **Verbindung konfigurieren:**
   - Geben Sie die IP-Adresse Ihres Linux Mint Rechners ein
   - Klicken Sie auf "Verbinden"

3. **Anmelden:**
   - Wählen Sie "Xorg" als Session-Typ (falls gefragt)
   - Geben Sie Ihren Linux-Benutzernamen und Passwort ein
   - Der Cinnamon-Desktop sollte erscheinen

## Firewall-Konfiguration

Falls Sie eine Firewall (ufw) aktiviert haben, müssen Sie Port 3389 freigeben:

```bash
sudo ufw allow 3389/tcp
```

## Status prüfen

```bash
# xrdp-Dienst Status
systemctl status xrdp

# Aktive Verbindungen auf Port 3389
ss -tlnp | grep 3389
```

## Bekannte Einschränkungen

- **Gleichzeitige Sitzungen:** Es kann immer nur eine Sitzung pro Benutzer aktiv sein
- **Lokale Sitzung:** Wenn Sie lokal am Linux-Rechner angemeldet sind, müssen Sie sich dort abmelden, bevor Sie sich remote verbinden können
- **Audio:** Audio-Weiterleitung ist standardmäßig nicht konfiguriert
- **Clipboard:** Zwischenablage-Synchronisation funktioniert möglicherweise nicht bei allen Anwendungen
- **Grafikleistung:** Aufwendige Grafikoperationen können langsamer sein als bei lokaler Nutzung

## Deinstallation

Um xrdp vollständig zu entfernen:

```bash
sudo systemctl stop xrdp
sudo systemctl disable xrdp
sudo apt remove --purge xrdp xorgxrdp -y
sudo rm -f /etc/polkit-1/rules.d/45-allow-colord.rules
```

## Fehlerbehebung

Siehe [docs/troubleshooting.md](docs/troubleshooting.md) für häufige Probleme und deren Lösungen.

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE) für Details.
