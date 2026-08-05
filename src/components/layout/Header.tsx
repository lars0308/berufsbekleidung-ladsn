"use client";

import Link from "next/link";
import { useState } from "react";
import { List, X, ShoppingCart, User } from "@phosphor-icons/react";
import { useCartStore } from "@/lib/cart-store";
import { cn } from "@/lib/cn";

const navLinks = [
  { href: "/shop", label: "Shop" },
  { href: "/konfigurator", label: "3D-Anprobe" },
  { href: "/impressum", label: "Kontakt" },
];

export function Header() {
  const [open, setOpen] = useState(false);
  const itemCount = useCartStore((s) =>
    s.lines.reduce((sum, l) => sum + l.qty, 0),
  );

  return (
    <header className="sticky top-0 z-50 border-b border-line bg-ink text-paper">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        <Link href="/" className="flex items-center gap-2 shrink-0">
          <span className="text-lg font-semibold tracking-tight">
            Krüger
          </span>
          <span className="hidden text-sm text-paper/60 sm:inline">
            Berufskleidungshaus
          </span>
        </Link>

        <nav className="hidden items-center gap-8 lg:flex" aria-label="Hauptnavigation">
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-sm font-medium text-paper/80 transition-colors hover:text-paper"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-2">
          <Link
            href="/login"
            className="hidden items-center gap-1.5 rounded-sm px-3 py-2 text-sm font-medium text-paper/80 transition-colors hover:text-paper sm:flex"
          >
            <User size={18} weight="regular" aria-hidden />
            Konto
          </Link>
          <Link
            href="/warenkorb"
            className="relative flex items-center gap-1.5 rounded-sm px-3 py-2 text-sm font-medium text-paper/80 transition-colors hover:text-paper"
            aria-label={`Warenkorb, ${itemCount} Artikel`}
          >
            <ShoppingCart size={20} weight="regular" aria-hidden />
            {itemCount > 0 && (
              <span className="absolute -right-0.5 -top-0.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-safety px-1 text-[10px] font-semibold text-white">
                {itemCount}
              </span>
            )}
          </Link>
          <button
            type="button"
            className="flex items-center justify-center rounded-sm p-2 text-paper lg:hidden"
            aria-label={open ? "Menü schließen" : "Menü öffnen"}
            aria-expanded={open}
            onClick={() => setOpen((v) => !v)}
          >
            {open ? <X size={22} /> : <List size={22} />}
          </button>
        </div>
      </div>

      <div
        className={cn(
          "overflow-hidden border-t border-paper/10 lg:hidden",
          open ? "max-h-64" : "max-h-0 border-t-0",
        )}
      >
        <nav
          className="flex flex-col gap-1 px-4 py-3"
          aria-label="Mobile Navigation"
        >
          {[...navLinks, { href: "/login", label: "Konto" }].map((link) => (
            <Link
              key={link.href}
              href={link.href}
              onClick={() => setOpen(false)}
              className="rounded-sm px-2 py-2.5 text-sm font-medium text-paper/85 hover:bg-paper/5 hover:text-paper"
            >
              {link.label}
            </Link>
          ))}
        </nav>
      </div>
    </header>
  );
}
