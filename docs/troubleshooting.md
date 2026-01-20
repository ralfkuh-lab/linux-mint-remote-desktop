# Fehlerbehebung

Dieses Dokument beschreibt häufige Probleme bei der Verwendung von xrdp auf Linux Mint und deren Lösungen.

## Inhaltsverzeichnis

- [Verbindungsprobleme](#verbindungsprobleme)
- [Anmeldeprobleme](#anmeldeprobleme)
- [Desktop-Probleme](#desktop-probleme)
- [Performance-Probleme](#performance-probleme)
- [Sonstige Probleme](#sonstige-probleme)

---

## Verbindungsprobleme

### Verbindung wird abgelehnt

**Symptom:** Windows zeigt "Remote Desktop kann keine Verbindung herstellen"

**Mögliche Ursachen und Lösungen:**

1. **xrdp-Dienst läuft nicht**
   ```bash
   # Status prüfen
   systemctl status xrdp

   # Dienst starten
   sudo systemctl start xrdp
   ```

2. **Firewall blockiert Port 3389**
   ```bash
   # Port freigeben (ufw)
   sudo ufw allow 3389/tcp

   # Firewall-Status prüfen
   sudo ufw status
   ```

3. **Falsche IP-Adresse**
   ```bash
   # Aktuelle IP-Adresse ermitteln
   hostname -I
   ```

### Verbindung wird nach kurzer Zeit getrennt

**Symptom:** Verbindung wird aufgebaut, aber sofort wieder getrennt

**Lösung:**
```bash
# xrdp-Log prüfen
sudo tail -50 /var/log/xrdp.log
sudo tail -50 /var/log/xrdp-sesman.log
```

---

## Anmeldeprobleme

### Authentifizierung fehlgeschlagen

**Symptom:** Benutzername und Passwort werden nicht akzeptiert

**Mögliche Ursachen:**

1. **Falsches Passwort** - Prüfen Sie Caps Lock und Tastaturlayout
2. **Benutzer existiert nicht** - Verwenden Sie einen lokalen Linux-Benutzer

### Authentifizierungsdialog erscheint

**Symptom:** Nach der Anmeldung erscheint ein Popup zur Authentifizierung

**Lösung:** Polkit-Regel neu erstellen
```bash
sudo tee /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla > /dev/null << 'EOF'
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

# xrdp neu starten
sudo systemctl restart xrdp
```

---

## Desktop-Probleme

### Schwarzer Bildschirm nach Anmeldung

**Symptom:** Nach erfolgreicher Anmeldung bleibt der Bildschirm schwarz

**Lösungen:**

1. **Lokale Sitzung beenden**
   - Melden Sie sich am lokalen Linux-Rechner ab
   - Versuchen Sie die Remote-Verbindung erneut

2. **Session-Typ prüfen**
   - Wählen Sie "Xorg" statt "Xvnc" im Anmeldefenster

3. **Startwm-Datei prüfen**
   ```bash
   # Falls .xsession nicht existiert oder fehlerhaft ist
   echo "cinnamon-session" > ~/.xsession
   chmod +x ~/.xsession
   ```

### Desktop startet, aber ohne Panels/Menüs

**Symptom:** Desktop erscheint, aber Cinnamon-Panel fehlt

**Lösung:**
```bash
# Cinnamon zurücksetzen
rm -rf ~/.cinnamon
rm -rf ~/.local/share/cinnamon

# Erneut verbinden
```

---

## Performance-Probleme

### Langsame/ruckelige Darstellung

**Symptom:** Mausbewegungen und Fenster reagieren verzögert

**Lösungen:**

1. **Farbtiefe reduzieren** (Windows-Client)
   - Öffnen Sie mstsc
   - Klicken Sie auf "Optionen anzeigen"
   - Tab "Anzeige" → Farbtiefe auf "Hohe Farbqualität (15 Bit)" setzen

2. **Visuelle Effekte deaktivieren**
   ```bash
   # In Cinnamon: Systemeinstellungen → Effekte → Alle deaktivieren
   ```

3. **Netzwerkqualität prüfen**
   - Verwenden Sie eine kabelgebundene Verbindung statt WLAN
   - Prüfen Sie die Netzwerkauslastung

---

## Sonstige Probleme

### Zwischenablage funktioniert nicht

**Symptom:** Copy & Paste zwischen Windows und Linux funktioniert nicht

**Lösung:**
```bash
# xrdp-cliprdr prüfen
ps aux | grep cliprdr

# Falls nicht vorhanden, xrdp neu installieren
sudo apt install --reinstall xrdp xorgxrdp
```

### Tastaturlayout falsch

**Symptom:** Tastatureingaben werden falsch interpretiert

**Lösung:**
```bash
# xrdp-Konfiguration anpassen
sudo nano /etc/xrdp/xrdp.ini

# In der Sektion [Globals] hinzufügen oder anpassen:
# keyboard_layout=de

# xrdp neu starten
sudo systemctl restart xrdp
```

### Mehrere Monitore werden nicht unterstützt

**Symptom:** Nur ein Monitor wird verwendet, obwohl mehrere konfiguriert sind

**Info:** Multi-Monitor-Unterstützung in xrdp ist begrenzt. Alternativen:
- Einzelne große Auflösung verwenden
- Für volle Multi-Monitor-Unterstützung: VNC oder andere Lösungen in Betracht ziehen

---

## Logs und Diagnose

### Wichtige Log-Dateien

```bash
# xrdp Hauptlog
sudo tail -100 /var/log/xrdp.log

# Session Manager Log
sudo tail -100 /var/log/xrdp-sesman.log

# System Journal
sudo journalctl -u xrdp -n 50

# Auth-Log (für Anmeldeprobleme)
sudo tail -50 /var/log/auth.log
```

### Dienste prüfen

```bash
# xrdp Status
systemctl status xrdp

# xrdp-sesman Status
systemctl status xrdp-sesman

# Ports prüfen
ss -tlnp | grep -E "(3389|3350)"
```

---

## Weitere Hilfe

Falls Ihr Problem hier nicht aufgeführt ist:

1. Prüfen Sie die Log-Dateien auf Fehlermeldungen
2. Suchen Sie nach der Fehlermeldung im Internet
3. Erstellen Sie ein Issue im [GitHub Repository](https://github.com/ralfkret/linux-mint-remote-desktop/issues)
