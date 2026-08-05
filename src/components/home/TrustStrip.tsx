const stats = [
  { value: "3", label: "Generationen Familienbetrieb in Lindhorst" },
  { value: "500+", label: "Artikel dauerhaft auf Lager" },
  { value: "24h", label: "Express-Versand bei Bestellung vor 14 Uhr" },
];

export function TrustStrip() {
  return (
    <section className="border-y border-line bg-paper-dim">
      <div className="mx-auto grid max-w-7xl grid-cols-1 gap-8 px-4 py-14 sm:grid-cols-3 sm:px-6 lg:px-8">
        {stats.map((stat) => (
          <div key={stat.label}>
            <p className="text-4xl font-semibold tracking-tight text-brand">
              {stat.value}
            </p>
            <p className="mt-2 max-w-[26ch] text-sm text-ink-soft">
              {stat.label}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}
