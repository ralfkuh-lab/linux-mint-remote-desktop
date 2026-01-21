# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

## [1.1.0] - 2026-01-21

### Hinzugefügt
- Interaktive Auswahl zwischen zwei Polkit-Stufen bei der Installation
- **Stufe 1 (Basis):** color-manager, PackageKit, Flatpak - reduziert häufige Auth-Dialoge
- **Stufe 2 (Erweitert):** zusätzlich NetworkManager und UDisks2 für Netzwerk- und Laufwerksverwaltung
- Automatische Entfernung alter Polkit-Regeln (45-allow-colord.rules)
- Dokumentation der Polkit-Stufen in README.md

### Geändert
- Polkit-Regel umbenannt von `45-allow-colord.rules` zu `45-xrdp-allow.rules`
- Erweiterte Polkit-Regel mit Unterstützung für PackageKit und Flatpak (Basis)
- Aktualisierte Deinstallationsanleitung in README.md

## [1.0.1] - 2026-01-20

### Behoben
- Linux Mint Info-Parsing: Verwende `grep` statt `source` um Fehler bei unquotierten Werten in `/etc/linuxmint/info` zu vermeiden
- Polkit-Regel: Aktualisiert auf modernes JavaScript-Format in `/etc/polkit-1/rules.d/` (das alte `.pkla`-Format wird von neueren Ubuntu/Mint-Versionen nicht mehr unterstützt)

### Geändert
- Dokumentation aktualisiert mit dem neuen Polkit-Format

## [1.0.0] - 2026-01-20

### Hinzugefügt
- Initiales Release des Linux Mint Remote Desktop Setup Scripts
- Automatische Installation von xrdp und xorgxrdp
- Erkennung und Validierung der Linux Mint Version (21.x/22.x)
- Prüfung auf bestehende xrdp-Installation
- Polkit-Regel für Cinnamon Desktop (verhindert Authentifizierungsdialog)
- Farbige Statusmeldungen während der Installation
- Anzeige der IP-Adresse nach erfolgreicher Installation
- Benutzerbestätigung vor Installation
- Umfassende README-Dokumentation
- Troubleshooting-Guide für häufige Probleme
- MIT-Lizenz
