"use client";

import { motion } from "motion/react";
import { ShieldCheck, Truck, MapPin } from "@phosphor-icons/react";
import { Button } from "@/components/ui/Button";

const badges = [
  { icon: ShieldCheck, label: "DGUV-zertifiziert" },
  { icon: Truck, label: "Express-Versand" },
  { icon: MapPin, label: "Fachberatung aus Lindhorst" },
];

export function Hero() {
  return (
    <section className="relative overflow-hidden bg-ink text-paper">
      <div className="mx-auto grid max-w-7xl items-center gap-10 px-4 py-16 sm:px-6 lg:grid-cols-[1.1fr_0.9fr] lg:gap-16 lg:py-24 lg:px-8">
        <div>
          <motion.h1
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
            className="text-4xl font-semibold leading-[1.05] tracking-tight sm:text-5xl lg:text-6xl"
          >
            Profiqualität für Handwerk, Industrie &amp; Pflege.
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.1, ease: [0.22, 1, 0.36, 1] }}
            className="mt-5 max-w-[46ch] text-base leading-relaxed text-paper/75"
          >
            Norm-sichere Arbeitskleidung und persönliche Schutzausrüstung,
            handverlesen für Handwerker, Pflegekräfte und Gastronomen.
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
            className="mt-8 flex flex-wrap items-center gap-4"
          >
            <Button href="/shop" variant="primary">
              Jetzt Sortiment entdecken
            </Button>
            <Button href="/konfigurator" variant="ghost" className="text-paper hover:text-white">
              Zur 3D-Anprobe
            </Button>
          </motion.div>

          <motion.ul
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.7, delay: 0.35 }}
            className="mt-10 flex flex-wrap gap-x-8 gap-y-3"
          >
            {badges.map(({ icon: Icon, label }) => (
              <li
                key={label}
                className="flex items-center gap-2 text-sm text-paper/70"
              >
                <Icon size={18} weight="regular" aria-hidden />
                {label}
              </li>
            ))}
          </motion.ul>
        </div>

        <motion.div
          initial={{ opacity: 0, scale: 0.97 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
          className="relative aspect-[4/5] w-full overflow-hidden rounded-sm lg:aspect-[3/4]"
        >
          <img
            src="https://picsum.photos/seed/krueger-hero-handwerker/900/1200"
            alt="Handwerker in Arbeitskleidung von Berufskleidungshaus Krüger"
            className="h-full w-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-ink/40 via-transparent to-transparent" />
        </motion.div>
      </div>
    </section>
  );
}
