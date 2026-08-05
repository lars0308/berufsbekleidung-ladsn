export const metadata = { title: "AGB | Berufskleidungshaus Krüger" };

export default function AgbPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 sm:px-6">
      <h1 className="text-3xl font-semibold tracking-tight">
        Allgemeine Geschäftsbedingungen
      </h1>

      <div className="mt-8 space-y-8 text-sm leading-relaxed text-ink-soft">
        <section>
          <h2 className="text-base font-medium text-ink">
            § 1 Geltungsbereich
          </h2>
          <p className="mt-2">
            Diese Allgemeinen Geschäftsbedingungen gelten für alle
            Bestellungen über den Online-Shop von Berufskleidungshaus
            Krüger, Inh. Frank Krüger, Bahnhofstraße 47, 31698 Lindhorst.
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            § 2 Vertragsschluss
          </h2>
          <p className="mt-2">
            Die Darstellung der Produkte im Shop stellt kein bindendes
            Angebot dar, sondern eine Aufforderung zur Bestellung. Mit dem
            Absenden der Bestellung geben Sie ein verbindliches Angebot zum
            Kauf ab. Der Vertrag kommt durch unsere Auftragsbestätigung per
            E-Mail zustande.
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            § 3 Preise und Versandkosten
          </h2>
          <p className="mt-2">
            Alle Preise verstehen sich inklusive der gesetzlichen
            Umsatzsteuer. Zusätzlich anfallende Versandkosten werden vor
            Abschluss der Bestellung transparent ausgewiesen.
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">§ 4 Zahlung</h2>
          <p className="mt-2">
            Die Zahlung erfolgt wahlweise per Rechnung, Vorkasse oder
            Nachnahme. Weitere Zahlungsarten werden im Bestellprozess
            angezeigt.
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            § 5 Lieferung und Eigentumsvorbehalt
          </h2>
          <p className="mt-2">
            Die Lieferung erfolgt innerhalb Deutschlands, sofern nicht anders
            angegeben. Die Ware bleibt bis zur vollständigen Bezahlung unser
            Eigentum.
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            § 6 Widerrufsrecht für Verbraucher
          </h2>
          <p className="mt-2">
            Verbrauchern steht ein gesetzliches Widerrufsrecht von 14 Tagen
            ab Erhalt der Ware zu. Zur Ausübung des Widerrufsrechts müssen
            Sie uns mittels einer eindeutigen Erklärung (z. B. per Post oder
            E-Mail) über Ihren Entschluss informieren. Zur Wahrung der Frist
            genügt die rechtzeitige Absendung der Widerrufserklärung.
          </p>
          <p className="mt-2">
            Im Falle eines Widerrufs sind die empfangenen Waren unverzüglich,
            spätestens jedoch innerhalb von 14 Tagen ab Mitteilung des
            Widerrufs, zurückzusenden. Die unmittelbaren Kosten der
            Rücksendung trägt der Kunde.
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            § 7 Gewährleistung
          </h2>
          <p className="mt-2">
            Es gelten die gesetzlichen Gewährleistungsrechte.
          </p>
        </section>

        <section>
          <h2 className="text-base font-medium text-ink">
            § 8 Schlussbestimmungen
          </h2>
          <p className="mt-2">
            Es gilt das Recht der Bundesrepublik Deutschland unter Ausschluss
            des UN-Kaufrechts. Sollte eine Bestimmung dieser AGB unwirksam
            sein, bleibt die Wirksamkeit der übrigen Bestimmungen unberührt.
          </p>
        </section>

        <p className="border-t border-line pt-6 text-xs">
          Diese Vorlage wurde automatisiert erstellt und ersetzt keine
          Rechtsberatung. Bitte lassen Sie die AGB vor Veröffentlichung
          rechtlich prüfen.
        </p>
      </div>
    </div>
  );
}
