"use client";

import { useState } from "react";
import { useCookieConsent, writeConsent } from "@/lib/cookie-consent";
import { Button } from "@/components/ui/Button";
import { cn } from "@/lib/cn";

function Toggle({
  checked,
  disabled,
  onChange,
  label,
}: {
  checked: boolean;
  disabled?: boolean;
  onChange?: () => void;
  label: string;
}) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      onClick={onChange}
      className={cn(
        "relative h-6 w-11 shrink-0 rounded-full transition-colors disabled:opacity-40",
        checked ? "bg-brand" : "bg-ink/15",
      )}
    >
      <span
        className={cn(
          "absolute top-0.5 h-5 w-5 rounded-full bg-white shadow-sm transition-transform",
          checked ? "translate-x-5" : "translate-x-0.5",
        )}
      />
    </button>
  );
}

export function CookieSettingsContent() {
  const consent = useCookieConsent();
  const [draft, setDraft] = useState<{ analytics: boolean; marketing: boolean } | null>(null);
  const [saved, setSaved] = useState(false);

  const analytics = draft?.analytics ?? consent?.analytics ?? false;
  const marketing = draft?.marketing ?? consent?.marketing ?? false;

  function save() {
    writeConsent({ analytics, marketing });
    setSaved(true);
    window.setTimeout(() => setSaved(false), 2500);
  }

  return (
    <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6">
      <h1 className="text-3xl font-semibold tracking-tight">
        Cookie-Einstellungen
      </h1>
      <p className="mt-2 text-sm leading-relaxed text-ink-soft">
        Verwalten Sie hier, welche Cookies und Analyse-Tools auf dieser Seite
        aktiv sein dürfen. Ihre Auswahl können Sie jederzeit ändern.
      </p>

      <div className="mt-8 space-y-4">
        <div className="flex items-start justify-between gap-4 rounded-sm border border-line p-5">
          <div>
            <p className="text-sm font-medium text-ink">Technisch notwendig</p>
            <p className="mt-1 text-sm text-ink-soft">
              Erforderlich für Warenkorb, Login-Status und Cookie-Einstellungen.
              Können nicht deaktiviert werden.
            </p>
          </div>
          <Toggle checked label="Technisch notwendige Cookies (immer aktiv)" disabled />
        </div>

        <div className="flex items-start justify-between gap-4 rounded-sm border border-line p-5">
          <div>
            <p className="text-sm font-medium text-ink">Analyse</p>
            <p className="mt-1 text-sm text-ink-soft">
              Hilft uns zu verstehen, wie der Shop genutzt wird, um ihn zu
              verbessern.
            </p>
          </div>
          <Toggle
            checked={analytics}
            onChange={() => setDraft({ analytics: !analytics, marketing })}
            label="Analyse-Cookies"
          />
        </div>

        <div className="flex items-start justify-between gap-4 rounded-sm border border-line p-5">
          <div>
            <p className="text-sm font-medium text-ink">Marketing</p>
            <p className="mt-1 text-sm text-ink-soft">
              Wird für personalisierte Angebote und Werbemaßnahmen verwendet.
            </p>
          </div>
          <Toggle
            checked={marketing}
            onChange={() => setDraft({ analytics, marketing: !marketing })}
            label="Marketing-Cookies"
          />
        </div>
      </div>

      <div className="mt-8 flex items-center gap-4">
        <Button variant="primary" onClick={save}>
          Auswahl speichern
        </Button>
        {saved && <p className="text-sm text-ink-soft">Gespeichert.</p>}
      </div>
    </div>
  );
}
