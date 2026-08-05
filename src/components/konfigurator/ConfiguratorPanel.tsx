"use client";

import { useState } from "react";
import dynamic from "next/dynamic";
import { cn } from "@/lib/cn";
import type { GarmentKey, GarmentState } from "@/components/konfigurator/types";

const MannequinScene = dynamic(
  () =>
    import("@/components/konfigurator/MannequinScene").then(
      (mod) => mod.MannequinScene,
    ),
  {
    ssr: false,
    loading: () => (
      <div className="flex h-full w-full items-center justify-center text-sm text-ink-soft">
        3D-Szene wird geladen…
      </div>
    ),
  },
);

const garmentMeta: { key: GarmentKey; label: string; colors: { label: string; hex: string }[] }[] = [
  {
    key: "jacke",
    label: "Softshelljacke",
    colors: [
      { label: "Graphit", hex: "#2a2c31" },
      { label: "Handwerker-Blau", hex: "#1e40af" },
      { label: "Schwarz", hex: "#121316" },
    ],
  },
  {
    key: "hose",
    label: "Arbeitshose",
    colors: [
      { label: "Anthrazit", hex: "#3d3f45" },
      { label: "Khaki", hex: "#6b6350" },
      { label: "Schwarz", hex: "#1a1b1e" },
    ],
  },
  {
    key: "weste",
    label: "Warnschutzweste",
    colors: [
      { label: "Safety-Orange", hex: "#ea580c" },
      { label: "Safety-Gelb", hex: "#eab308" },
      { label: "Safety-Rot", hex: "#dc2626" },
    ],
  },
  {
    key: "muetze",
    label: "Mütze",
    colors: [
      { label: "Navy", hex: "#1e3a8a" },
      { label: "Schwarz", hex: "#121316" },
      { label: "Graphit", hex: "#2a2c31" },
    ],
  },
];

export function ConfiguratorPanel() {
  const [state, setState] = useState<GarmentState>({
    visible: { jacke: true, hose: true, weste: false, muetze: false },
    colors: { jacke: "#2a2c31", hose: "#3d3f45", weste: "#ea580c", muetze: "#1e3a8a" },
  });

  function toggle(key: GarmentKey) {
    setState((s) => ({ ...s, visible: { ...s.visible, [key]: !s.visible[key] } }));
  }

  function setColor(key: GarmentKey, hex: string) {
    setState((s) => ({ ...s, colors: { ...s.colors, [key]: hex } }));
  }

  return (
    <div className="grid gap-8 lg:grid-cols-[1fr_360px] lg:gap-10">
      <div className="aspect-square overflow-hidden rounded-sm bg-paper-dim lg:aspect-[4/5]">
        <MannequinScene state={state} />
      </div>

      <div className="space-y-8">
        {garmentMeta.map((garment) => (
          <div key={garment.key} className="border-b border-line pb-6 last:border-0">
            <div className="flex items-center justify-between">
              <p className="text-sm font-medium text-ink">{garment.label}</p>
              <button
                type="button"
                role="switch"
                aria-checked={state.visible[garment.key]}
                aria-label={`${garment.label} ${state.visible[garment.key] ? "ausziehen" : "anziehen"}`}
                onClick={() => toggle(garment.key)}
                className={cn(
                  "relative h-6 w-11 shrink-0 rounded-full transition-colors",
                  state.visible[garment.key] ? "bg-brand" : "bg-ink/15",
                )}
              >
                <span
                  className={cn(
                    "absolute top-0.5 h-5 w-5 rounded-full bg-white shadow-sm transition-transform",
                    state.visible[garment.key] ? "translate-x-5" : "translate-x-0.5",
                  )}
                />
              </button>
            </div>

            {state.visible[garment.key] && (
              <div className="mt-3 flex gap-2">
                {garment.colors.map((c) => (
                  <button
                    key={c.hex}
                    type="button"
                    aria-label={c.label}
                    aria-pressed={state.colors[garment.key] === c.hex}
                    onClick={() => setColor(garment.key, c.hex)}
                    className={cn(
                      "h-8 w-8 rounded-full border-2 transition-transform",
                      state.colors[garment.key] === c.hex
                        ? "border-brand scale-110"
                        : "border-transparent hover:scale-105",
                    )}
                    style={{ backgroundColor: c.hex }}
                  />
                ))}
              </div>
            )}
          </div>
        ))}

        <p className="text-xs leading-relaxed text-ink-soft">
          Stilisierte Voransicht zur Kombination von Farben und Teilen. Für
          exakte Passform empfehlen wir zusätzlich die Größentabelle je
          Artikel im Shop.
        </p>
      </div>
    </div>
  );
}
