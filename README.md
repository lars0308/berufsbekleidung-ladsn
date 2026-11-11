# Unser Spiel

Ein Koop-Rätselspiel für zwei, gespielt am geteilten Bildschirm (Splitscreen) – gebaut mit **Godot 4.3+**.

## Spielprinzip

Ihr steuert zwei Figuren mit unterschiedlichen Fähigkeiten. Beide müssen gleichzeitig auf ihrem Zielfeld stehen.

| Figur | Steuerung | Fähigkeit |
|-------|-----------|-----------|
| 🦊 Fuchs | `W A S D` oder Controller 1 | passt durch schmale Spalte (`~`), kann nichts schieben |
| 🐻 Bär | Pfeiltasten oder Controller 2 | schiebt Kisten, passt nicht durch Spalte |

- **Druckplatten** öffnen Türen gleicher Farbe, solange eine Figur oder Kiste darauf steht.
- `R` startet das Level neu, `Enter` geht nach dem Lösen zum nächsten Level.

## Starten

1. [Godot 4.3 oder neuer](https://godotengine.org/download) installieren.
2. Diesen Ordner im Projektmanager importieren (`project.godot`).
3. `F5` drücken.

## Aufbau

- `scenes/main.tscn` – Startszene
- `scripts/main.gd` – Splitscreen (zwei Kameras, gemeinsame Welt), Eingaben, Anzeige
- `scripts/level.gd` – Spiellogik und Zeichnen
- `scripts/levels.gd` – alle Level als Text-Karten (neue Level einfach ergänzen)
