import { formatEUR } from "@/lib/format";
import { FREE_SHIPPING_THRESHOLD } from "@/lib/cart-store";

export function OrderSummary({
  subtotal,
  shipping,
  total,
  vat,
}: {
  subtotal: number;
  shipping: number;
  total: number;
  vat: number;
}) {
  return (
    <div className="rounded-sm border border-line bg-paper p-6">
      <h2 className="text-sm font-medium text-ink">Zusammenfassung</h2>

      <dl className="mt-4 space-y-2.5 text-sm">
        <div className="flex justify-between">
          <dt className="text-ink-soft">Zwischensumme</dt>
          <dd className="text-ink">{formatEUR(subtotal)}</dd>
        </div>
        <div className="flex justify-between">
          <dt className="text-ink-soft">Versand</dt>
          <dd className="text-ink">
            {shipping === 0 ? "Kostenlos" : formatEUR(shipping)}
          </dd>
        </div>
        {shipping > 0 && (
          <p className="text-xs text-ink-soft">
            Ab {formatEUR(FREE_SHIPPING_THRESHOLD)} Bestellwert versandkostenfrei.
          </p>
        )}
        <div className="flex justify-between border-t border-line pt-2.5 text-base font-medium">
          <dt className="text-ink">Gesamt</dt>
          <dd className="text-ink">{formatEUR(total)}</dd>
        </div>
        <div className="flex justify-between text-xs text-ink-soft">
          <dt>davon enthaltene MwSt.</dt>
          <dd>{formatEUR(vat)}</dd>
        </div>
      </dl>
    </div>
  );
}
