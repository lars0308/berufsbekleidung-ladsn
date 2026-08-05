"use client";

import Link from "next/link";
import { Badge } from "@/components/ui/Badge";
import { formatEUR } from "@/lib/format";
import { cn } from "@/lib/cn";
import type { Product } from "@/lib/products";

export function ProductCard({
  product,
  dimmed,
  onHoverStart,
  onHoverEnd,
}: {
  product: Product;
  dimmed: boolean;
  onHoverStart: () => void;
  onHoverEnd: () => void;
}) {
  return (
    <Link
      href={`/shop/${product.slug}`}
      onMouseEnter={onHoverStart}
      onMouseLeave={onHoverEnd}
      onFocus={onHoverStart}
      onBlur={onHoverEnd}
      className={cn(
        "group block transition-[filter,opacity] duration-300 ease-out",
        dimmed && "opacity-60 blur-[2px]",
      )}
    >
      <div className="aspect-[3/4] overflow-hidden rounded-sm bg-paper-dim">
        <img
          src={`https://picsum.photos/seed/${product.imageSeed}/700/900`}
          alt={product.name}
          className="h-full w-full object-cover transition-transform duration-500 [transition-timing-function:cubic-bezier(0.16,1,0.3,1)] group-hover:scale-105"
        />
      </div>

      {product.badges.length > 0 && (
        <div className="mt-3 flex flex-wrap gap-1.5">
          {product.badges.map((b) => (
            <Badge key={b} tone={b.includes("DGUV") ? "safety" : "brand"}>
              {b}
            </Badge>
          ))}
        </div>
      )}

      <p className="mt-3 text-sm font-medium text-ink">{product.name}</p>
      <p className="mt-1 text-sm text-ink-soft">{formatEUR(product.price)}</p>
    </Link>
  );
}
