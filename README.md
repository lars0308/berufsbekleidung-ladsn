# Berufskleidungshaus Krüger — Online-Shop

Next.js (App Router, static export) für den Online-Shop von Berufskleidungshaus
Krüger in Lindhorst: Mehrseiten-Shop, 3D-Anprobe-Konfigurator (React Three
Fiber), Warenkorb/Checkout (UI-Flow ohne echte Zahlungsabwicklung) und
rechtssichere Seiten.

## Entwicklung

```bash
npm install
npm run dev
```

Öffne [http://localhost:3000](http://localhost:3000).

## Build (statischer HTML-Export)

```bash
npm run build
```

Erzeugt reines HTML/CSS/JS im Ordner `out/` (kein Server nötig,
`next.config.ts` setzt `output: "export"`).

## Deployment auf GitHub Pages

`.github/workflows/deploy-pages.yml` baut bei jedem Push automatisch und
veröffentlicht `out/` auf GitHub Pages. Damit das greift, muss im Repository
unter **Settings → Pages → Source** einmalig auf **GitHub Actions**
umgestellt werden.

## Struktur

- `src/app/` — Seiten (Startseite, `/shop`, `/konfigurator`, `/warenkorb`,
  `/checkout`, `/login`, `/registrieren`, Rechtsseiten)
- `src/components/` — UI-, Layout-, Shop-, Konfigurator- und
  Warenkorb-Komponenten
- `src/lib/` — Produktdaten (Platzhalter), Warenkorb-Store (Zustand),
  Cookie-Consent
- `.claude/skills/` — Claude-Code-Skills für Design, Animation und 3D
