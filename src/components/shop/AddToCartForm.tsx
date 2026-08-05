"use client";

import { useState } from "react";
import { CheckCircle } from "@phosphor-icons/react";
import { Button } from "@/components/ui/Button";
import { useCartStore } from "@/lib/cart-store";
import type { Product } from "@/lib/products";

export function AddToCartForm({ product }: { product: Product }) {
  const [size, setSize] = useState(product.sizes[0]);
  const [qty, setQty] = useState(1);
  const [added, setAdded] = useState(false);
  const add = useCartStore((s) => s.add);

  return (
    <form
      className="mt-8 space-y-6"
      onSubmit={(e) => {
        e.preventDefault();
        add(product.slug, size, qty);
        setAdded(true);
        window.setTimeout(() => setAdded(false), 2000);
      }}
    >
      <div className="flex flex-col gap-2">
        <label htmlFor="size" className="text-sm font-medium text-ink">
          Größe
        </label>
        <select
          id="size"
          value={size}
          onChange={(e) => setSize(e.target.value)}
          className="w-full max-w-xs rounded-sm border border-line bg-paper px-3 py-2.5 text-sm text-ink focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand"
        >
          {product.sizes.map((s) => (
            <option key={s} value={s}>
              {s}
            </option>
          ))}
        </select>
      </div>

      <div className="flex flex-col gap-2">
        <label htmlFor="qty" className="text-sm font-medium text-ink">
          Menge
        </label>
        <input
          id="qty"
          type="number"
          min={1}
          max={20}
          value={qty}
          onChange={(e) =>
            setQty(Math.max(1, Math.min(20, Number(e.target.value) || 1)))
          }
          className="w-24 rounded-sm border border-line bg-paper px-3 py-2.5 text-sm text-ink focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand"
        />
      </div>

      <Button type="submit" variant="primary" className="w-full sm:w-auto">
        {added ? (
          <>
            <CheckCircle size={18} weight="bold" aria-hidden />
            Zum Warenkorb hinzugefügt
          </>
        ) : (
          "In den Warenkorb"
        )}
      </Button>
    </form>
  );
}
