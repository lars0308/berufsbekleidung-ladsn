"use client";

import Link from "next/link";
import { Trash, Minus, Plus } from "@phosphor-icons/react";
import { formatEUR } from "@/lib/format";
import { useCartStore } from "@/lib/cart-store";
import type { Product } from "@/lib/products";

export function CartLineItem({
  product,
  size,
  qty,
}: {
  product: Product;
  size: string;
  qty: number;
}) {
  const updateQty = useCartStore((s) => s.updateQty);
  const remove = useCartStore((s) => s.remove);

  return (
    <div className="flex gap-4 border-b border-line py-6 first:pt-0 last:border-0">
      <Link
        href={`/shop/${product.slug}`}
        className="h-24 w-20 shrink-0 overflow-hidden rounded-sm bg-paper-dim"
      >
        <img
          src={`https://picsum.photos/seed/${product.imageSeed}/200/260`}
          alt={product.name}
          className="h-full w-full object-cover"
        />
      </Link>

      <div className="flex flex-1 flex-col justify-between">
        <div className="flex items-start justify-between gap-4">
          <div>
            <Link
              href={`/shop/${product.slug}`}
              className="text-sm font-medium text-ink hover:text-brand"
            >
              {product.name}
            </Link>
            <p className="mt-1 text-sm text-ink-soft">Größe: {size}</p>
          </div>
          <p className="text-sm font-medium text-ink">
            {formatEUR(product.price * qty)}
          </p>
        </div>

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 rounded-sm border border-line">
            <button
              type="button"
              aria-label="Menge verringern"
              onClick={() => updateQty(product.slug, size, qty - 1)}
              className="flex h-8 w-8 items-center justify-center text-ink-soft hover:text-ink"
            >
              <Minus size={14} />
            </button>
            <span className="w-6 text-center text-sm">{qty}</span>
            <button
              type="button"
              aria-label="Menge erhöhen"
              onClick={() => updateQty(product.slug, size, qty + 1)}
              className="flex h-8 w-8 items-center justify-center text-ink-soft hover:text-ink"
            >
              <Plus size={14} />
            </button>
          </div>

          <button
            type="button"
            aria-label={`${product.name} entfernen`}
            onClick={() => remove(product.slug, size)}
            className="flex items-center gap-1.5 text-sm text-ink-soft hover:text-safety"
          >
            <Trash size={16} />
            Entfernen
          </button>
        </div>
      </div>
    </div>
  );
}
