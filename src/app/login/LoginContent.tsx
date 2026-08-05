"use client";

import { useState, type FormEvent } from "react";
import Link from "next/link";
import { Info } from "@phosphor-icons/react";
import { Field } from "@/components/checkout/Field";
import { Button } from "@/components/ui/Button";

export function LoginContent() {
  const [submitted, setSubmitted] = useState(false);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setSubmitted(true);
  }

  return (
    <div className="mx-auto max-w-md px-4 py-16 sm:px-6">
      <h1 className="text-3xl font-semibold tracking-tight">Anmelden</h1>
      <p className="mt-2 text-sm text-ink-soft">
        Für Privat- und B2B-Kunden von Berufskleidungshaus Krüger.
      </p>

      {submitted && (
        <div className="mt-6 flex gap-2 rounded-sm border border-brand/30 bg-brand/5 p-4 text-sm text-ink">
          <Info size={18} className="mt-0.5 shrink-0 text-brand" aria-hidden />
          <p>
            Dies ist eine Demo-Anmeldung ohne verbundenes Kundenkonto-System.
            Ihre Eingaben wurden nicht übertragen.
          </p>
        </div>
      )}

      <form onSubmit={handleSubmit} className="mt-6 space-y-4">
        <Field id="email" label="E-Mail-Adresse" type="email" autoComplete="email" required />
        <Field id="password" label="Passwort" type="password" autoComplete="current-password" required />

        <label className="flex items-center gap-2 text-sm text-ink-soft">
          <input type="checkbox" className="accent-brand" />
          Angemeldet bleiben
        </label>

        <Button type="submit" variant="primary" className="w-full">
          Anmelden
        </Button>
      </form>

      <p className="mt-6 text-sm text-ink-soft">
        Noch kein Konto?{" "}
        <Link href="/registrieren" className="font-medium text-brand hover:underline">
          Jetzt registrieren
        </Link>
      </p>
    </div>
  );
}
