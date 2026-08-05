import { cn } from "@/lib/cn";

export function Badge({
  children,
  tone = "brand",
  className,
}: {
  children: React.ReactNode;
  tone?: "brand" | "safety" | "ink";
  className?: string;
}) {
  const toneClasses = {
    brand: "bg-brand/10 text-brand",
    safety: "bg-safety-soft text-safety",
    ink: "bg-ink text-paper",
  } as const;

  return (
    <span
      className={cn(
        "inline-flex items-center rounded-sm px-2.5 py-1 text-xs font-medium tracking-wide",
        toneClasses[tone],
        className,
      )}
    >
      {children}
    </span>
  );
}
