export type GarmentKey = "jacke" | "hose" | "weste" | "muetze";

export interface GarmentState {
  visible: Record<GarmentKey, boolean>;
  colors: Record<GarmentKey, string>;
}
