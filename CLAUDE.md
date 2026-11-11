# Lumi & Kiri

Lokales 2-Spieler-Koop-3D-Spiel in **Godot 4.3** (GDScript). Immer Splitscreen, zwei Xbox-Controller, ein Windows-PC.
Spieldesign und Roadmap: siehe Masterprompt des Nutzers (P0 Basis, P1 Level 1, P2 Level 2, P3 Politur).

- Szenen und Welt werden größtenteils im Code gebaut (`scripts/`), kein Editor nötig.
- Tests: `godot --headless --path . --fixed-fps 120 --script res://tests/p0_test.gd` (muss vorher einmal `--import` laufen).
- Screenshot per Software-Renderer: siehe Kopf von `tests/screenshot.gd`.
- Kollisionsebenen: 1 Welt, 2 Spieler, 4 Gegner, 8 Schattentor.
- Das Centris-Projekt des Nutzers darf nie angefasst werden.
