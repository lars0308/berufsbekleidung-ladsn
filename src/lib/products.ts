export type Category = "handwerk" | "medizin" | "gastro" | "zunft";

export const categories: { id: Category; label: string }[] = [
  { id: "handwerk", label: "Handwerk" },
  { id: "medizin", label: "Medizin" },
  { id: "gastro", label: "Gastro" },
  { id: "zunft", label: "Zunft" },
];

export interface Product {
  id: string;
  slug: string;
  name: string;
  category: Category;
  price: number;
  vatRate: number;
  sizes: string[];
  description: string;
  badges: string[];
  imageSeed: string;
}

export const products: Product[] = [
  {
    id: "p-01",
    slug: "canvas-arbeitshose-vollstretch",
    name: "Canvas-Arbeitshose Vollstretch",
    category: "handwerk",
    price: 79.9,
    vatRate: 0.19,
    sizes: ["44", "46", "48", "50", "52", "54", "56"],
    description:
      "Verstärktes Canvas-Gewebe mit Vollstretch-Einsätzen an Knie und Bund. Cordura-Kniepolstertaschen, zwölf Fächer für Werkzeug und Zollstock.",
    badges: ["Bestseller", "Cordura verstärkt"],
    imageSeed: "krueger-arbeitshose-canvas",
  },
  {
    id: "p-02",
    slug: "softshelljacke-graphit",
    name: "Softshelljacke Graphit",
    category: "handwerk",
    price: 94.5,
    vatRate: 0.19,
    sizes: ["S", "M", "L", "XL", "XXL", "3XL"],
    description:
      "Winddichte, wasserabweisende Softshelljacke mit atmungsaktiver Membran. Reflexbesatz für Sichtbarkeit bei Dämmerung.",
    badges: ["Wind- & wasserdicht"],
    imageSeed: "krueger-softshelljacke-graphit",
  },
  {
    id: "p-03",
    slug: "warnschutzweste-klasse-2",
    name: "Warnschutzweste Klasse 2",
    category: "handwerk",
    price: 14.9,
    vatRate: 0.19,
    sizes: ["Einheitsgröße"],
    description:
      "Zertifiziert nach EN ISO 20471 Klasse 2. Reißverschluss, zwei Brusttaschen, maschinenwaschbar bis 60 °C.",
    badges: ["DGUV-zertifiziert"],
    imageSeed: "krueger-warnweste",
  },
  {
    id: "p-04",
    slug: "sicherheitsstiefel-s3",
    name: "Sicherheitsstiefel S3 SRC",
    category: "handwerk",
    price: 119.0,
    vatRate: 0.19,
    sizes: ["39", "40", "41", "42", "43", "44", "45", "46"],
    description:
      "Stahlkappe, durchtrittsichere Zwischensohle, rutschhemmend nach SRC. Wasserdichtes Obermaterial aus Vollnarbenleder.",
    badges: ["S3 SRC", "DGUV-zertifiziert"],
    imageSeed: "krueger-sicherheitsstiefel",
  },
  {
    id: "p-05",
    slug: "medizin-kasack-unisex",
    name: "Kasack Unisex Comfort",
    category: "medizin",
    price: 32.9,
    vatRate: 0.19,
    sizes: ["XS", "S", "M", "L", "XL", "XXL"],
    description:
      "Pflegeleichter Mischgewebe-Kasack, 60 °C waschbar und trockneroptimiert. Vier Taschen für Stethoskop, Stift und Handschuhe.",
    badges: ["Bestseller"],
    imageSeed: "krueger-kasack-comfort",
  },
  {
    id: "p-06",
    slug: "medizin-hose-jogger",
    name: "Funktionshose Jogger-Schnitt",
    category: "medizin",
    price: 28.5,
    vatRate: 0.19,
    sizes: ["XS", "S", "M", "L", "XL", "XXL"],
    description:
      "Elastischer Bund mit Tunnelzug, seitliche Eingrifftaschen, atmungsaktives Mischgewebe für lange Schichten.",
    badges: [],
    imageSeed: "krueger-jogger-medizin",
  },
  {
    id: "p-07",
    slug: "laborkittel-langarm",
    name: "Laborkittel Langarm",
    category: "medizin",
    price: 41.9,
    vatRate: 0.19,
    sizes: ["44", "46", "48", "50", "52", "54"],
    description:
      "Flüssigkeitsabweisendes Baumwollgewebe, Druckknopfleiste, Brust- und Seitentaschen. Normgerecht für Labor und Praxis.",
    badges: ["DGUV-zertifiziert"],
    imageSeed: "krueger-laborkittel",
  },
  {
    id: "p-08",
    slug: "kochjacke-klassisch",
    name: "Kochjacke Klassisch",
    category: "gastro",
    price: 36.9,
    vatRate: 0.19,
    sizes: ["44", "46", "48", "50", "52", "54", "56"],
    description:
      "Doppelreihige Knopfleiste, hitzeisolierender Kragen, verstärkte Nähte. 100 % Baumwolle für hohen Tragekomfort in der Küche.",
    badges: ["Bestseller"],
    imageSeed: "krueger-kochjacke",
  },
  {
    id: "p-09",
    slug: "servierschuerze-lang",
    name: "Servierschürze Lang",
    category: "gastro",
    price: 16.5,
    vatRate: 0.19,
    sizes: ["Einheitsgröße"],
    description:
      "Robuste Baumwoll-Polyester-Mischung, zwei geräumige Fronttaschen, verstellbarer Nackenriemen.",
    badges: [],
    imageSeed: "krueger-servierschuerze",
  },
  {
    id: "p-10",
    slug: "rutschfeste-gastro-schuhe",
    name: "Rutschfeste Gastro-Schuhe",
    category: "gastro",
    price: 68.0,
    vatRate: 0.19,
    sizes: ["37", "38", "39", "40", "41", "42", "43", "44", "45"],
    description:
      "Zertifiziert nach EN ISO 20347, rutschhemmende Sohle SRC, atmungsaktives Obermaterial, leicht zu reinigen.",
    badges: ["SRC zertifiziert"],
    imageSeed: "krueger-gastro-schuhe",
  },
  {
    id: "p-11",
    slug: "zunft-cord-jacke",
    name: "Zunft-Cordjacke Traditionell",
    category: "zunft",
    price: 189.0,
    vatRate: 0.19,
    sizes: ["44", "46", "48", "50", "52", "54", "56"],
    description:
      "Handgearbeitete Cordjacke nach traditionellem Schnitt, Perlmuttknöpfe, verstärkte Ellenbogen. Für Gesellenwanderung und Zunfttreffen.",
    badges: ["Handgefertigt"],
    imageSeed: "krueger-zunftjacke-cord",
  },
  {
    id: "p-12",
    slug: "zunft-weste-samt",
    name: "Zunftweste Samt",
    category: "zunft",
    price: 84.0,
    vatRate: 0.19,
    sizes: ["44", "46", "48", "50", "52", "54"],
    description:
      "Klassische Samtweste mit sechs Perlmuttknöpfen, gefüttert, nach überlieferter Zunftordnung geschnitten.",
    badges: [],
    imageSeed: "krueger-zunftweste-samt",
  },
];

export function getProductsByCategory(category?: Category) {
  if (!category) return products;
  return products.filter((p) => p.category === category);
}

export function getProductBySlug(slug: string) {
  return products.find((p) => p.slug === slug);
}
