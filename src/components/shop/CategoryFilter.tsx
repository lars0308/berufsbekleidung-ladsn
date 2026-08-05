"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { categories, type Category } from "@/lib/products";
import { cn } from "@/lib/cn";

export function CategoryFilter() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const active = searchParams.get("kategorie") as Category | null;

  function select(category: Category | null) {
    const params = new URLSearchParams(searchParams.toString());
    if (category) {
      params.set("kategorie", category);
    } else {
      params.delete("kategorie");
    }
    const query = params.toString();
    router.push(query ? `/shop?${query}` : "/shop");
  }

  return (
    <div
      className="flex flex-wrap gap-2"
      role="group"
      aria-label="Nach Branche filtern"
    >
      <button
        type="button"
        onClick={() => select(null)}
        aria-pressed={!active}
        className={cn(
          "rounded-sm border px-4 py-2 text-sm font-medium transition-colors",
          !active
            ? "border-ink bg-ink text-paper"
            : "border-line text-ink-soft hover:border-ink/40",
        )}
      >
        Alle
      </button>
      {categories.map((cat) => (
        <button
          key={cat.id}
          type="button"
          onClick={() => select(cat.id)}
          aria-pressed={active === cat.id}
          className={cn(
            "rounded-sm border px-4 py-2 text-sm font-medium transition-colors",
            active === cat.id
              ? "border-ink bg-ink text-paper"
              : "border-line text-ink-soft hover:border-ink/40",
          )}
        >
          {cat.label}
        </button>
      ))}
    </div>
  );
}
