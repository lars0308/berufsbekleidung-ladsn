"use client";

import { Canvas } from "@react-three/fiber";
import { OrbitControls, ContactShadows } from "@react-three/drei";
import { Mannequin } from "@/components/konfigurator/Mannequin";
import { Hose, Jacke, Weste, Muetze } from "@/components/konfigurator/Garments";
import type { GarmentState } from "@/components/konfigurator/types";

export function MannequinScene({ state }: { state: GarmentState }) {
  return (
    <Canvas
      shadows
      frameloop="demand"
      dpr={[1, 2]}
      camera={{ position: [2.1, 1.4, 2.8], fov: 38 }}
      gl={{ antialias: true }}
    >
      <color attach="background" args={["#efeef0"]} />

      <ambientLight intensity={0.55} />
      <directionalLight
        position={[3, 4, 2]}
        intensity={1.4}
        castShadow
        shadow-mapSize={[1024, 1024]}
        shadow-camera-near={0.5}
        shadow-camera-far={10}
        shadow-camera-left={-2}
        shadow-camera-right={2}
        shadow-camera-top={2}
        shadow-camera-bottom={-2}
      />
      <directionalLight position={[-3, 2, -2]} intensity={0.4} />
      <hemisphereLight args={["#ffffff", "#3a3a3a", 0.35]} />

      <Mannequin />
      <Jacke color={state.colors.jacke} visible={state.visible.jacke} />
      <Hose color={state.colors.hose} visible={state.visible.hose} />
      <Weste color={state.colors.weste} visible={state.visible.weste} />
      <Muetze color={state.colors.muetze} visible={state.visible.muetze} />

      <ContactShadows
        position={[0, 0.005, 0]}
        opacity={0.45}
        scale={3}
        blur={2.4}
        far={2}
      />

      <OrbitControls
        makeDefault
        enableDamping
        dampingFactor={0.08}
        minDistance={2}
        maxDistance={4.2}
        minPolarAngle={Math.PI / 6}
        maxPolarAngle={Math.PI / 1.9}
        target={[0, 0.85, 0]}
      />
    </Canvas>
  );
}
