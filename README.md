# Lumi & Kiri

Ein süßes 3D-Koop-Abenteuer für zwei Spieler an einem PC: Zwei kleine Aliens, Lumi (Licht) und Kiri (Schatten), sind auf einem fremden Dschungelplaneten gestrandet, haben sich verloren und müssen einander und ihr Raumschiff finden.

- Godot **4.3**, lokaler Koop mit **zwei Xbox-Controllern**, ständiger vertikaler **Splitscreen**
- Steuerung: [CONTROLS.md](CONTROLS.md), Quellen: [CREDITS.md](CREDITS.md)

## Starten

1. Godot 4.3 öffnen, `project.godot` importieren (erster Import dauert, Assets werden verarbeitet).
2. `F5`.

## Stand

- **P0 Basis:** Splitscreen, zwei Xbox-Controller, Bewegung, Lumis Licht-Dash mit Gleiten, Kiris Schatten-Dash, 3er-Kombo, Gegner, Checkpoints, Pause.
- **Level 1 "Getrennt unter zwei Sonnen":** getrennte Routen (sonnig / Schatten), Lichtung mit der Fee Zirp, Koop-Rätsel (Kristall -> Schattenplatte -> Schattenbrücke -> Wurzeltor), Aussichtspunkt mit Schiffswrack.
- Figuren sind noch Platzhalter aus Formen. Level 2, Intro, Menü, Einstellungen und Sound fehlen noch.

## Tests

```
godot --headless --import --path .
godot --headless --path . --fixed-fps 120 --script res://tests/p0_test.gd      # Mechanik auf der Teststrecke
godot --headless --path . --fixed-fps 120 --script res://tests/level1_test.gd  # Bot läuft beide Routen + Rätsel
```
