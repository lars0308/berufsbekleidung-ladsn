"use client";

import { create } from "zustand";
import { persist } from "zustand/middleware";
import { getProductBySlug } from "@/lib/products";

export interface CartLine {
  slug: string;
  size: string;
  qty: number;
}

interface CartState {
  lines: CartLine[];
  add: (slug: string, size: string, qty: number) => void;
  updateQty: (slug: string, size: string, qty: number) => void;
  remove: (slug: string, size: string) => void;
  clear: () => void;
}

export const useCartStore = create<CartState>()(
  persist(
    (set) => ({
      lines: [],
      add: (slug, size, qty) =>
        set((state) => {
          const existing = state.lines.find(
            (l) => l.slug === slug && l.size === size,
          );
          if (existing) {
            return {
              lines: state.lines.map((l) =>
                l.slug === slug && l.size === size
                  ? { ...l, qty: l.qty + qty }
                  : l,
              ),
            };
          }
          return { lines: [...state.lines, { slug, size, qty }] };
        }),
      updateQty: (slug, size, qty) =>
        set((state) => ({
          lines:
            qty <= 0
              ? state.lines.filter(
                  (l) => !(l.slug === slug && l.size === size),
                )
              : state.lines.map((l) =>
                  l.slug === slug && l.size === size ? { ...l, qty } : l,
                ),
        })),
      remove: (slug, size) =>
        set((state) => ({
          lines: state.lines.filter(
            (l) => !(l.slug === slug && l.size === size),
          ),
        })),
      clear: () => set({ lines: [] }),
    }),
    { name: "krueger-warenkorb" },
  ),
);

export const SHIPPING_COST = 5.9;
export const FREE_SHIPPING_THRESHOLD = 100;

export function cartTotals(lines: CartLine[]) {
  const items = lines
    .map((line) => {
      const product = getProductBySlug(line.slug);
      if (!product) return null;
      return { line, product };
    })
    .filter((x): x is { line: CartLine; product: NonNullable<ReturnType<typeof getProductBySlug>> } => x !== null);

  const subtotal = items.reduce(
    (sum, { line, product }) => sum + product.price * line.qty,
    0,
  );
  const shipping = subtotal === 0 || subtotal >= FREE_SHIPPING_THRESHOLD ? 0 : SHIPPING_COST;
  const total = subtotal + shipping;
  const vat = items.reduce(
    (sum, { line, product }) =>
      sum + (product.price * line.qty * product.vatRate) / (1 + product.vatRate),
    0,
  );

  return { items, subtotal, shipping, total, vat };
}
