import { notFound } from "next/navigation";
import { getProductBySlug, products, categories } from "@/lib/products";
import { Badge } from "@/components/ui/Badge";
import { AddToCartForm } from "@/components/shop/AddToCartForm";
import { formatEUR } from "@/lib/format";
import { pexelsUrl } from "@/lib/images";

export function generateStaticParams() {
  return products.map((p) => ({ slug: p.slug }));
}

export default async function ProductPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const product = getProductBySlug(slug);
  if (!product) notFound();

  const categoryLabel = categories.find((c) => c.id === product.category)?.label;

  return (
    <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
      <div className="grid gap-10 lg:grid-cols-2 lg:gap-16">
        <div className="aspect-[3/4] overflow-hidden rounded-sm bg-paper-dim">
          <img
            src={pexelsUrl(product.imageId, 900, 1200)}
            alt={product.name}
            className="h-full w-full object-cover"
          />
        </div>

        <div>
          {categoryLabel && (
            <p className="text-xs font-medium uppercase tracking-[0.14em] text-ink-soft">
              {categoryLabel}
            </p>
          )}
          <h1 className="mt-2 text-3xl font-semibold tracking-tight">
            {product.name}
          </h1>
          <p className="mt-3 text-xl text-ink-soft">
            {formatEUR(product.price)}{" "}
            <span className="text-sm">inkl. MwSt.</span>
          </p>

          {product.badges.length > 0 && (
            <div className="mt-4 flex flex-wrap gap-1.5">
              {product.badges.map((b) => (
                <Badge key={b} tone={b.includes("DGUV") ? "safety" : "brand"}>
                  {b}
                </Badge>
              ))}
            </div>
          )}

          <p className="mt-6 max-w-[60ch] text-sm leading-relaxed text-ink-soft">
            {product.description}
          </p>

          <AddToCartForm product={product} />
        </div>
      </div>
    </div>
  );
}
