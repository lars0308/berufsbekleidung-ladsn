import { ConfiguratorPanel } from "@/components/konfigurator/ConfiguratorPanel";

export default function KonfiguratorPage() {
  return (
    <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
      <div className="max-w-[60ch]">
        <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">
          3D-Anprobe
        </h1>
        <p className="mt-3 text-sm leading-relaxed text-ink-soft">
          Kombinieren Sie Jacke, Hose, Weste und Mütze direkt im Browser und
          drehen Sie die Ansicht per Maus oder Touch.
        </p>
      </div>

      <div className="mt-10">
        <ConfiguratorPanel />
      </div>
    </div>
  );
}
