import { Suspense } from "react";
import { ShopContent } from "@/app/shop/ShopContent";

export default function ShopPage() {
  return (
    <Suspense fallback={null}>
      <ShopContent />
    </Suspense>
  );
}
