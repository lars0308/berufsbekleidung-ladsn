"use client";

import { useState, type FormEvent } from "react";
import Link from "next/link";
import { Info } from "@phosphor-icons/react";
import { Field } from "@/components/checkout/Field";
import { Button } from "@/components/ui/Button";
import { cn } from "@/lib/cn";

type AccountType = "privat" | "b2b";

export function RegistrierenContent() {
  const [accountType, setAccountType] = useState<AccountType>("privat");
  const [submitted, setSubmitted] = useState(false);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setSubmitted(true);
  }

  return (
    <div className="mx-auto max-w-md px-4 py-16 sm:px-6">
      <h1 className="text-3xl font-semibold tracking-tight">Konto erstellen</h1>
      <p className="mt-2 text-sm text-ink-soft">
        Für schnellere Bestellungen und Zugriff auf B2B-Konditionen.
      </p>

      {submitted && (
        <div className="mt-6 flex gap-2 rounded-sm border border-brand/30 bg-brand/5 p-4 text-sm text-ink">
          <Info size={18} className="mt-0.5 shrink-0 text-brand" aria-hidden />
          <p>
            Dies ist eine Demo-Registrierung ohne verbundenes
            Kundenkonto-System. Ihre Eingaben wurden nicht übertragen.
          </p>
        </div>
      )}

      <div
        className="mt-6 flex gap-2 rounded-sm border border-line p-1"
        role="radiogroup"
        aria-label="Kontotyp"
      >
        {(["privat", "b2b"] as const).map((type) => (
          <button
            key={type}
            type="button"
            role="radio"
            aria-checked={accountType === type}
            onClick={() => setAccountType(type)}
            className={cn(
              "flex-1 rounded-sm px-4 py-2 text-sm font-medium transition-colors",
              accountType === type ? "bg-ink text-paper" : "text-ink-soft",
            )}
          >
            {type === "privat" ? "Privatkunde" : "Geschäftskunde"}
          </button>
        ))}
      </div>

      <form onSubmit={handleSubmit} className="mt-6 space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <Field id="vorname" label="Vorname" autoComplete="given-name" required />
          <Field id="nachname" label="Nachname" autoComplete="family-name" required />
        </div>
        {accountType === "b2b" && (
          <Field id="firma" label="Firma" autoComplete="organization" required />
        )}
        <Field id="email" label="E-Mail-Adresse" type="email" autoComplete="email" required />
        <Field
          id="password"
          label="Passwort"
          type="password"
          autoComplete="new-password"
          required
        />

        <Button type="submit" variant="primary" className="w-full">
          Konto erstellen
        </Button>
      </form>

      <p className="mt-6 text-sm text-ink-soft">
        Bereits registriert?{" "}
        <Link href="/login" className="font-medium text-brand hover:underline">
          Jetzt anmelden
        </Link>
      </p>
    </div>
  );
}
