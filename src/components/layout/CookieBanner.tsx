"use client";

import Link from "next/link";
import { useCookieConsent, writeConsent } from "@/lib/cookie-consent";
import { Button } from "@/components/ui/Button";

export function CookieBanner() {
  const consent = useCookieConsent();

  if (consent !== null) return null;

  return (
    <div
      role="dialog"
      aria-label="Cookie-Einstellungen"
      className="fixed inset-x-0 bottom-0 z-[60] border-t border-line bg-paper px-4 py-5 shadow-[0_-8px_24px_rgba(18,19,22,0.08)] sm:px-6"
    >
      <div className="mx-auto flex max-w-7xl flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <p className="max-w-[65ch] text-sm leading-relaxed text-ink-soft">
          Wir nutzen technisch notwendige Cookies für den Betrieb dieser
          Seite. Mit Ihrer Zustimmung setzen wir zusätzlich Analyse-Cookies,
          um den Shop zu verbessern. Details in unserer{" "}
          <Link href="/datenschutz" className="underline underline-offset-2">
            Datenschutzerklärung
          </Link>
          .
        </p>
        <div className="flex shrink-0 flex-wrap gap-3">
          <Button
            variant="secondary"
            onClick={() => writeConsent({ analytics: false, marketing: false })}
          >
            Nur notwendige
          </Button>
          <Button
            variant="primary"
            onClick={() => writeConsent({ analytics: true, marketing: true })}
          >
            Alle akzeptieren
          </Button>
        </div>
      </div>
    </div>
  );
}
