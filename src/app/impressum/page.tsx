export const metadata = { title: "Impressum | Berufskleidungshaus Krüger" };

export default function ImpressumPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 sm:px-6">
      <h1 className="text-3xl font-semibold tracking-tight">Impressum</h1>

      <div className="mt-8 space-y-8 text-sm leading-relaxed text-ink-soft">
        <section>
          <h2 className="text-base font-medium text-ink">
            Angaben gemäß § 5 TMG
          </h2>
          <p className="mt-2">
            Berufskleidungshaus Krüger
            <br />
            Inh. Frank Krüger
            <br />
            Bahnhofstraße 47
            <br />
            31698 Lindhorst
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">Kontakt</h2>
          <p className="mt-2">
            Telefon: [bitte ergänzen]
            <br />
            E-Mail: [bitte ergänzen]
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            Umsatzsteuer-Identifikationsnummer
          </h2>
          <p className="mt-2">
            Umsatzsteuer-Identifikationsnummer gemäß § 27 a Umsatzsteuergesetz:
            [bitte ergänzen]
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            Verantwortlich für den Inhalt nach § 55 Abs. 2 RStV
          </h2>
          <p className="mt-2">
            Frank Krüger
            <br />
            Bahnhofstraße 47
            <br />
            31698 Lindhorst
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            EU-Streitschlichtung
          </h2>
          <p className="mt-2">
            Die Europäische Kommission stellt eine Plattform zur
            Online-Streitbeilegung (OS) bereit, abrufbar unter{" "}
            <a
              href="https://ec.europa.eu/consumers/odr/"
              className="underline underline-offset-2 hover:text-brand"
              target="_blank"
              rel="noreferrer"
            >
              https://ec.europa.eu/consumers/odr/
            </a>
            . Unsere E-Mail-Adresse finden Sie oben im Impressum.
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            Verbraucherstreitbeilegung
          </h2>
          <p className="mt-2">
            Wir sind nicht bereit oder verpflichtet, an
            Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle
            teilzunehmen.
          </p>
        </section>

        <p className="border-t border-line pt-6 text-xs">
          Diese Vorlage wurde automatisiert erstellt und ersetzt keine
          Rechtsberatung. Bitte prüfen und vervollständigen Sie die mit
          „[bitte ergänzen]&rdquo; markierten Angaben, bevor die Seite
          veröffentlicht wird.
        </p>
      </div>
    </div>
  );
}
