"use client";

import { useState, type FormEvent } from "react";
import { CheckCircle } from "@phosphor-icons/react";
import { useCartStore, cartTotals } from "@/lib/cart-store";
import { OrderSummary } from "@/components/cart/OrderSummary";
import { Field } from "@/components/checkout/Field";
import { Button } from "@/components/ui/Button";
import { formatEUR } from "@/lib/format";
import { useHydrated } from "@/lib/use-hydrated";

type FormValues = {
  vorname: string;
  nachname: string;
  firma: string;
  strasse: string;
  plz: string;
  ort: string;
  email: string;
  telefon: string;
};

const initialValues: FormValues = {
  vorname: "",
  nachname: "",
  firma: "",
  strasse: "",
  plz: "",
  ort: "",
  email: "",
  telefon: "",
};

const paymentOptions = [
  { id: "rechnung", label: "Kauf auf Rechnung" },
  { id: "vorkasse", label: "Vorkasse" },
  { id: "nachnahme", label: "Nachnahme" },
] as const;

export function CheckoutContent() {
  const hydrated = useHydrated();
  const lines = useCartStore((s) => s.lines);
  const clear = useCartStore((s) => s.clear);

  const [values, setValues] = useState<FormValues>(initialValues);
  const [errors, setErrors] = useState<Partial<FormValues>>({});
  const [payment, setPayment] = useState<(typeof paymentOptions)[number]["id"]>("rechnung");
  const [orderNumber, setOrderNumber] = useState<string | null>(null);

  if (!hydrated) return null;

  if (orderNumber) {
    return (
      <div className="mx-auto max-w-7xl px-4 py-24 text-center sm:px-6 lg:px-8">
        <CheckCircle size={40} weight="fill" className="mx-auto text-brand" aria-hidden />
        <h1 className="mt-4 text-2xl font-semibold tracking-tight">
          Vielen Dank für Ihre Bestellung
        </h1>
        <p className="mt-2 text-sm text-ink-soft">
          Ihre Bestellnummer lautet <strong className="text-ink">{orderNumber}</strong>.
          Eine Bestätigung senden wir Ihnen per E-Mail.
        </p>
        <div className="mt-6">
          <Button href="/shop" variant="primary">
            Weiter einkaufen
          </Button>
        </div>
      </div>
    );
  }

  if (lines.length === 0) {
    return (
      <div className="mx-auto max-w-7xl px-4 py-24 text-center sm:px-6 lg:px-8">
        <h1 className="text-2xl font-semibold tracking-tight">
          Ihr Warenkorb ist leer
        </h1>
        <p className="mt-2 text-sm text-ink-soft">
          Legen Sie zunächst Artikel in den Warenkorb, um zur Kasse zu gehen.
        </p>
        <div className="mt-6">
          <Button href="/shop" variant="primary">
            Zum Sortiment
          </Button>
        </div>
      </div>
    );
  }

  const { subtotal, shipping, total, vat } = cartTotals(lines);

  function validate(): boolean {
    const next: Partial<FormValues> = {};
    if (!values.vorname.trim()) next.vorname = "Bitte geben Sie Ihren Vornamen an.";
    if (!values.nachname.trim()) next.nachname = "Bitte geben Sie Ihren Nachnamen an.";
    if (!values.strasse.trim()) next.strasse = "Bitte geben Sie Straße und Hausnummer an.";
    if (!/^\d{5}$/.test(values.plz.trim())) next.plz = "Bitte geben Sie eine gültige Postleitzahl an.";
    if (!values.ort.trim()) next.ort = "Bitte geben Sie den Ort an.";
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(values.email.trim()))
      next.email = "Bitte geben Sie eine gültige E-Mail-Adresse an.";
    setErrors(next);
    return Object.keys(next).length === 0;
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (!validate()) return;
    const generated = `K-${Math.floor(100000 + Math.random() * 900000)}`;
    setOrderNumber(generated);
    clear();
  }

  return (
    <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
      <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">Kasse</h1>

      <div className="mt-8 grid gap-10 lg:grid-cols-[1fr_360px]">
        <form onSubmit={handleSubmit} noValidate className="space-y-8">
          <fieldset className="space-y-4">
            <legend className="text-sm font-medium text-ink">Lieferadresse</legend>
            <div className="grid gap-4 sm:grid-cols-2">
              <Field
                id="vorname"
                label="Vorname"
                autoComplete="given-name"
                value={values.vorname}
                error={errors.vorname}
                onChange={(e) => setValues((v) => ({ ...v, vorname: e.target.value }))}
              />
              <Field
                id="nachname"
                label="Nachname"
                autoComplete="family-name"
                value={values.nachname}
                error={errors.nachname}
                onChange={(e) => setValues((v) => ({ ...v, nachname: e.target.value }))}
              />
            </div>
            <Field
              id="firma"
              label="Firma (optional, für B2B-Bestellungen)"
              autoComplete="organization"
              value={values.firma}
              onChange={(e) => setValues((v) => ({ ...v, firma: e.target.value }))}
            />
            <Field
              id="strasse"
              label="Straße und Hausnummer"
              autoComplete="street-address"
              value={values.strasse}
              error={errors.strasse}
              onChange={(e) => setValues((v) => ({ ...v, strasse: e.target.value }))}
            />
            <div className="grid gap-4 sm:grid-cols-[140px_1fr]">
              <Field
                id="plz"
                label="PLZ"
                autoComplete="postal-code"
                inputMode="numeric"
                value={values.plz}
                error={errors.plz}
                onChange={(e) => setValues((v) => ({ ...v, plz: e.target.value }))}
              />
              <Field
                id="ort"
                label="Ort"
                autoComplete="address-level2"
                value={values.ort}
                error={errors.ort}
                onChange={(e) => setValues((v) => ({ ...v, ort: e.target.value }))}
              />
            </div>
          </fieldset>

          <fieldset className="space-y-4">
            <legend className="text-sm font-medium text-ink">Kontakt</legend>
            <Field
              id="email"
              label="E-Mail-Adresse"
              type="email"
              autoComplete="email"
              value={values.email}
              error={errors.email}
              onChange={(e) => setValues((v) => ({ ...v, email: e.target.value }))}
            />
            <Field
              id="telefon"
              label="Telefon (optional)"
              type="tel"
              autoComplete="tel"
              value={values.telefon}
              onChange={(e) => setValues((v) => ({ ...v, telefon: e.target.value }))}
            />
          </fieldset>

          <fieldset className="space-y-3">
            <legend className="text-sm font-medium text-ink">Zahlungsart</legend>
            {paymentOptions.map((opt) => (
              <label
                key={opt.id}
                className="flex items-center gap-3 rounded-sm border border-line px-4 py-3 text-sm has-[:checked]:border-brand"
              >
                <input
                  type="radio"
                  name="payment"
                  value={opt.id}
                  checked={payment === opt.id}
                  onChange={() => setPayment(opt.id)}
                  className="accent-brand"
                />
                {opt.label}
              </label>
            ))}
            <p className="text-xs text-ink-soft">
              Dies ist eine Demo-Kasse ohne echte Zahlungsabwicklung.
            </p>
          </fieldset>

          <Button type="submit" variant="primary" className="w-full sm:w-auto">
            Zahlungspflichtig bestellen · {formatEUR(total)}
          </Button>
        </form>

        <div>
          <OrderSummary subtotal={subtotal} shipping={shipping} total={total} vat={vat} />
        </div>
      </div>
    </div>
  );
}
