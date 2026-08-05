"use client";

import { useSearchParams } from "next/navigation";
import { CategoryFilter } from "@/components/shop/CategoryFilter";
import { ProductGrid } from "@/components/shop/ProductGrid";
import { getProductsByCategory, categories, type Category } from "@/lib/products";

export function ShopContent() {
  const searchParams = useSearchParams();
  const category = searchParams.get("kategorie") as Category | null;
  const activeLabel = categories.find((c) => c.id === category)?.label;
  const products = getProductsByCategory(category ?? undefined);

  return (
    <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
      <div className="max-w-[50ch]">
        <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">
          {activeLabel ? `${activeLabel}` : "Gesamtes Sortiment"}
        </h1>
        <p className="mt-3 text-sm leading-relaxed text-ink-soft">
          Norm-sichere Arbeitskleidung und Schutzausrüstung, geprüft für den
          täglichen Einsatz.
        </p>
      </div>

      <div className="mt-8">
        <CategoryFilter />
      </div>

      <div className="mt-10">
        <ProductGrid products={products} />
      </div>
    </div>
  );
}
