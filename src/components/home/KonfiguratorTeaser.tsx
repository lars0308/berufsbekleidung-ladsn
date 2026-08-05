import { Button } from "@/components/ui/Button";

export function KonfiguratorTeaser() {
  return (
    <section className="mx-auto max-w-7xl px-4 py-16 sm:px-6 lg:px-8 lg:py-24">
      <div className="grid items-center gap-10 rounded-sm bg-ink px-6 py-12 text-paper sm:px-10 lg:grid-cols-2 lg:gap-16 lg:px-16 lg:py-16">
        <div>
          <h2 className="max-w-[22ch] text-2xl font-semibold tracking-tight sm:text-3xl">
            Vor der Bestellung virtuell anprobieren.
          </h2>
          <p className="mt-4 max-w-[50ch] text-sm leading-relaxed text-paper/70">
            Unser 3D-Konfigurator zeigt Arbeitshosen, Softshelljacken,
            Sicherheitswesten und Mützen an einer realistischen
            Schaufensterpuppe — direkt im Browser, ohne Download.
          </p>
          <div className="mt-8">
            <Button href="/konfigurator" variant="primary">
              Konfigurator öffnen
            </Button>
          </div>
        </div>

        <div className="aspect-[4/3] overflow-hidden rounded-sm bg-ink-soft">
          <img
            src="https://picsum.photos/seed/krueger-konfigurator-teaser/900/700"
            alt="Vorschau des 3D-Konfigurators von Berufskleidungshaus Krüger"
            className="h-full w-full object-cover"
          />
        </div>
      </div>
    </section>
  );
}
