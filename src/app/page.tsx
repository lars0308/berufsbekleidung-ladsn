import { Hero } from "@/components/home/Hero";
import { TrustStrip } from "@/components/home/TrustStrip";
import { CategoryGrid } from "@/components/home/CategoryGrid";
import { KonfiguratorTeaser } from "@/components/home/KonfiguratorTeaser";

export default function Home() {
  return (
    <>
      <Hero />
      <TrustStrip />
      <CategoryGrid />
      <KonfiguratorTeaser />
    </>
  );
}
