"use client";

import { ShoppingBag } from "@phosphor-icons/react";
import { useCartStore, cartTotals } from "@/lib/cart-store";
import { CartLineItem } from "@/components/cart/CartLineItem";
import { OrderSummary } from "@/components/cart/OrderSummary";
import { Button } from "@/components/ui/Button";
import { useHydrated } from "@/lib/use-hydrated";

export function WarenkorbContent() {
  const hydrated = useHydrated();
  const lines = useCartStore((s) => s.lines);

  if (!hydrated) return null;

  if (lines.length === 0) {
    return (
      <div className="mx-auto max-w-7xl px-4 py-24 text-center sm:px-6 lg:px-8">
        <ShoppingBag size={40} className="mx-auto text-ink-soft" aria-hidden />
        <h1 className="mt-4 text-2xl font-semibold tracking-tight">
          Ihr Warenkorb ist leer
        </h1>
        <p className="mt-2 text-sm text-ink-soft">
          Entdecken Sie unser Sortiment für Handwerk, Medizin, Gastro und Zunft.
        </p>
        <div className="mt-6">
          <Button href="/shop" variant="primary">
            Zum Sortiment
          </Button>
        </div>
      </div>
    );
  }

  const { items, subtotal, shipping, total, vat } = cartTotals(lines);

  return (
    <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
      <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">
        Warenkorb
      </h1>

      <div className="mt-8 grid gap-10 lg:grid-cols-[1fr_360px]">
        <div>
          {items.map(({ line, product }) => (
            <CartLineItem
              key={`${line.slug}-${line.size}`}
              product={product}
              size={line.size}
              qty={line.qty}
            />
          ))}
        </div>

        <div className="space-y-4">
          <OrderSummary subtotal={subtotal} shipping={shipping} total={total} vat={vat} />
          <Button href="/checkout" variant="primary" className="w-full">
            Zur Kasse
          </Button>
        </div>
      </div>
    </div>
  );
}
