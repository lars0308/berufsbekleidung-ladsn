import Link from "next/link";

const shopLinks = [
  { href: "/shop?kategorie=handwerk", label: "Handwerk" },
  { href: "/shop?kategorie=medizin", label: "Medizin" },
  { href: "/shop?kategorie=gastro", label: "Gastro" },
  { href: "/shop?kategorie=zunft", label: "Zunft" },
];

const legalLinks = [
  { href: "/impressum", label: "Impressum" },
  { href: "/datenschutz", label: "Datenschutz" },
  { href: "/agb", label: "AGB" },
  { href: "/cookie-einstellungen", label: "Cookie-Einstellungen" },
];

export function Footer() {
  return (
    <footer className="border-t border-line bg-ink text-paper/80">
      <div className="mx-auto grid max-w-7xl gap-10 px-4 py-14 sm:px-6 lg:grid-cols-4 lg:px-8">
        <div>
          <p className="text-lg font-semibold text-paper">
            Berufskleidungshaus Krüger
          </p>
          <p className="mt-3 max-w-[32ch] text-sm leading-relaxed">
            Profiqualität für Handwerk, Industrie, Medizin und Gastronomie.
            Fachberatung aus Lindhorst seit Generationen.
          </p>
        </div>

        <div>
          <p className="text-sm font-medium text-paper">Sortiment</p>
          <ul className="mt-4 space-y-2.5 text-sm">
            {shopLinks.map((l) => (
              <li key={l.href}>
                <Link href={l.href} className="hover:text-paper">
                  {l.label}
                </Link>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <p className="text-sm font-medium text-paper">Rechtliches</p>
          <ul className="mt-4 space-y-2.5 text-sm">
            {legalLinks.map((l) => (
              <li key={l.href}>
                <Link href={l.href} className="hover:text-paper">
                  {l.label}
                </Link>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <p className="text-sm font-medium text-paper">Kontakt</p>
          <address className="mt-4 space-y-1 text-sm not-italic">
            <p>Frank Krüger</p>
            <p>Bahnhofstraße 47</p>
            <p>31698 Lindhorst</p>
          </address>
        </div>
      </div>

      <div className="border-t border-paper/10">
        <p className="mx-auto max-w-7xl px-4 py-5 text-xs text-paper/50 sm:px-6 lg:px-8">
          © {new Date().getFullYear()} Berufskleidungshaus Krüger, Inh. Frank
          Krüger. Alle Rechte vorbehalten.
        </p>
      </div>
    </footer>
  );
}
