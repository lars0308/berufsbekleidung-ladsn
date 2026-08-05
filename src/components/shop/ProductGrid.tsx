"use client";

import { useState } from "react";
import { ProductCard } from "@/components/shop/ProductCard";
import type { Product } from "@/lib/products";

export function ProductGrid({ products }: { products: Product[] }) {
  const [hoveredId, setHoveredId] = useState<string | null>(null);

  if (products.length === 0) {
    return (
      <p className="py-16 text-center text-sm text-ink-soft">
        Keine Artikel in dieser Kategorie gefunden.
      </p>
    );
  }

  return (
    <div className="grid grid-cols-2 gap-x-5 gap-y-10 sm:grid-cols-3 lg:grid-cols-4">
      {products.map((product) => (
        <ProductCard
          key={product.id}
          product={product}
          dimmed={hoveredId !== null && hoveredId !== product.id}
          onHoverStart={() => setHoveredId(product.id)}
          onHoverEnd={() => setHoveredId(null)}
        />
      ))}
    </div>
  );
}
