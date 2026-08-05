export const metadata = { title: "Datenschutz | Berufskleidungshaus Krüger" };

export default function DatenschutzPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 sm:px-6">
      <h1 className="text-3xl font-semibold tracking-tight">
        Datenschutzerklärung
      </h1>

      <div className="mt-8 space-y-8 text-sm leading-relaxed text-ink-soft">
        <section>
          <h2 className="text-base font-medium text-ink">
            1. Verantwortlicher
          </h2>
          <p className="mt-2">
            Verantwortlicher im Sinne der Datenschutz-Grundverordnung (DSGVO)
            ist:
            <br />
            Berufskleidungshaus Krüger, Inh. Frank Krüger
            <br />
            Bahnhofstraße 47, 31698 Lindhorst
            <br />
            E-Mail: [bitte ergänzen]
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            2. Hosting bei GitHub Pages
          </h2>
          <p className="mt-2">
            Diese Website wird über GitHub Pages gehostet, einen Dienst der
            GitHub, Inc., 88 Colin P Kelly Jr St, San Francisco, CA 94107,
            USA. Beim Aufruf der Seite verarbeitet GitHub technisch
            notwendige Server-Logdaten (z. B. IP-Adresse, Datum und Uhrzeit
            des Zugriffs, aufgerufene Seite, Browsertyp), auch außerhalb der
            EU. Details finden Sie in der Datenschutzerklärung von GitHub:{" "}
            <a
              href="https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement"
              className="underline underline-offset-2 hover:text-brand"
              target="_blank"
              rel="noreferrer"
            >
              GitHub Privacy Statement
            </a>
            .
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            3. Cookies und Einwilligung
          </h2>
          <p className="mt-2">
            Wir setzen technisch notwendige Cookies ein, um grundlegende
            Funktionen wie den Warenkorb bereitzustellen. Darüber hinaus
            setzen wir Analyse-Cookies nur mit Ihrer Einwilligung ein, die
            Sie jederzeit unter{" "}
            <a
              href="/cookie-einstellungen"
              className="underline underline-offset-2 hover:text-brand"
            >
              Cookie-Einstellungen
            </a>{" "}
            widerrufen oder anpassen können.
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            4. Bestellungen und Kundenkonto
          </h2>
          <p className="mt-2">
            Bei einer Bestellung oder Registrierung erheben wir die zur
            Vertragsabwicklung erforderlichen Daten (z. B. Name, Anschrift,
            E-Mail-Adresse) auf Grundlage von Art. 6 Abs. 1 lit. b DSGVO. Eine
            Weitergabe an Dritte erfolgt nur, soweit dies zur
            Vertragserfüllung notwendig ist (z. B. Versanddienstleister).
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            5. Ihre Rechte
          </h2>
          <p className="mt-2">
            Sie haben das Recht auf Auskunft, Berichtigung, Löschung und
            Einschränkung der Verarbeitung Ihrer personenbezogenen Daten
            sowie ein Recht auf Datenübertragbarkeit und Widerspruch gegen
            die Verarbeitung. Wenden Sie sich hierzu an die oben genannte
            Kontaktadresse. Zudem steht Ihnen ein Beschwerderecht bei einer
            Datenschutz-Aufsichtsbehörde zu.
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
