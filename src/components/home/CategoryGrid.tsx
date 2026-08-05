import Link from "next/link";
import { categories } from "@/lib/products";

const imagery: Record<string, string> = {
  handwerk: "krueger-cat-handwerk",
  medizin: "krueger-cat-medizin",
  gastro: "krueger-cat-gastro",
  zunft: "krueger-cat-zunft",
};

export function CategoryGrid() {
  return (
    <section className="mx-auto max-w-7xl px-4 py-16 sm:px-6 lg:px-8 lg:py-24">
      <h2 className="max-w-[28ch] text-2xl font-semibold tracking-tight sm:text-3xl">
        Vier Branchen. Eine Werkstatt für Profiqualität.
      </h2>

      <div className="mt-10 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {categories.map((cat) => (
          <Link
            key={cat.id}
            href={`/shop?kategorie=${cat.id}`}
            className="group relative aspect-[3/4] overflow-hidden rounded-sm"
          >
            <img
              src={`https://picsum.photos/seed/${imagery[cat.id]}/600/800`}
              alt=""
              className="h-full w-full object-cover transition-transform duration-500 ease-out group-hover:scale-105"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-ink/80 via-ink/10 to-transparent" />
            <span className="absolute bottom-5 left-5 text-lg font-medium text-white">
              {cat.label}
            </span>
          </Link>
        ))}
      </div>
    </section>
  );
}
