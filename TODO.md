# Projektplan: Remote Desktop auf Linux Mint

## Projektübersicht
Einrichtung einer Remote Desktop Verbindung von Windows zu Linux Mint (Cinnamon) mittels xrdp, inklusive automatisiertem Setup-Script und GitHub-Repository.

## Gewählte Technologie
- **Remote Desktop Lösung:** xrdp
- **Desktop-Umgebung:** Cinnamon
- **Sicherheitsfeatures:** Basis (keine zusätzliche Firewall/SSH-Tunnel Konfiguration)

---

## TODO-Liste

### Phase 1: Repository & Grundstruktur
- [x] TODO.md Datei im Projekt speichern
- [x] GitHub Repository "linux-mint-remote-desktop" erstellen (via `gh repo create`)
- [x] Projektstruktur anlegen:
  ```
  /
  ├── README.md
  ├── CHANGELOG.md
  ├── TODO.md
  ├── LICENSE
  ├── setup-xrdp.sh
  └── docs/
      └── troubleshooting.md
  ```

### Phase 2: Dokumentation (README.md)
- [x] Projektbeschreibung schreiben
- [x] Systemvoraussetzungen dokumentieren
  - Linux Mint 21.x / 22.x mit Cinnamon
  - Sudo-Rechte erforderlich
- [x] Manuelle Installationsschritte dokumentieren
- [x] Anleitung für Windows-Client hinzufügen
- [x] Bekannte Einschränkungen notieren

### Phase 3: Setup-Script (setup-xrdp.sh)
- [x] Script-Header mit Beschreibung und Lizenz
- [x] Root/Sudo-Prüfung implementieren
- [x] Linux Mint Version erkennen und prüfen
- [x] Prüfung ob xrdp bereits installiert ist
- [x] Benutzerbestätigung vor Installation abfragen
- [x] xrdp und Abhängigkeiten installieren:
  - `xrdp`
  - `xorgxrdp`
- [x] Polkit-Regel für Cinnamon erstellen (vermeidet Authentifizierungsdialog)
- [x] xrdp-Dienst aktivieren und starten
- [x] Statusmeldungen und Erfolgsmeldung ausgeben
- [x] IP-Adresse des Systems anzeigen für einfache Verbindung

### Phase 4: Changelog
- [x] CHANGELOG.md im Keep-a-Changelog Format anlegen
- [x] Erste Version (1.0.0) dokumentieren

### Phase 5: Testing & Finalisierung
- [ ] Script auf Linux Mint testen
- [ ] Verbindung von Windows mit mstsc.exe testen
- [ ] README mit Screenshots/Beispielen ergänzen (optional)
- [x] Repository auf GitHub pushen

---

## Technische Details für das Script

### Benötigte Pakete
```bash
sudo apt update
sudo apt install xrdp xorgxrdp -y
```

### Polkit-Regel für Cinnamon
Datei: `/etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla`
```ini
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
```

### Dienst aktivieren
```bash
sudo systemctl enable xrdp
sudo systemctl start xrdp
```

---

## Verifizierung
1. Script auf Linux Mint ausführen
2. Prüfen ob xrdp-Dienst läuft: `systemctl status xrdp`
3. Von Windows: Win+R → `mstsc` → IP-Adresse des Linux-Rechners eingeben
4. Mit Linux-Benutzer anmelden
5. Cinnamon-Desktop sollte erscheinen
