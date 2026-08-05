export function Hose({ color, visible }: { color: string; visible: boolean }) {
  if (!visible) return null;
  return (
    <group>
      {[-1, 1].map((side) => (
        <mesh
          key={side}
          position={[0.1 * side, 0.44, 0]}
          castShadow
          receiveShadow
        >
          <capsuleGeometry args={[0.115, 0.76, 8, 16]} />
          <meshStandardMaterial color={color} roughness={0.88} metalness={0.02} />
        </mesh>
      ))}
      <mesh position={[0, 0.86, 0]} castShadow receiveShadow>
        <capsuleGeometry args={[0.225, 0.1, 8, 16]} />
        <meshStandardMaterial color={color} roughness={0.88} metalness={0.02} />
      </mesh>
    </group>
  );
}

export function Jacke({ color, visible }: { color: string; visible: boolean }) {
  if (!visible) return null;
  return (
    <group>
      <mesh position={[0, 1.16, 0]} castShadow receiveShadow>
        <capsuleGeometry args={[0.235, 0.44, 8, 16]} />
        <meshStandardMaterial color={color} roughness={0.55} metalness={0.05} />
      </mesh>
      {[-1, 1].map((side) => (
        <mesh
          key={side}
          position={[0.29 * side, 1.16, 0]}
          rotation={[0, 0, side * 0.12]}
          castShadow
          receiveShadow
        >
          <capsuleGeometry args={[0.075, 0.48, 8, 16]} />
          <meshStandardMaterial color={color} roughness={0.55} metalness={0.05} />
        </mesh>
      ))}
    </group>
  );
}

export function Weste({ color, visible }: { color: string; visible: boolean }) {
  if (!visible) return null;
  return (
    <group>
      <mesh position={[0, 1.2, 0]} castShadow receiveShadow>
        <capsuleGeometry args={[0.245, 0.32, 8, 16]} />
        <meshStandardMaterial color={color} roughness={0.82} metalness={0.02} />
      </mesh>
      {[1.32, 1.08].map((y) => (
        <mesh key={y} position={[0, y, 0]}>
          <cylinderGeometry args={[0.25, 0.25, 0.05, 32, 1, true]} />
          <meshStandardMaterial
            color="#f5f5f0"
            roughness={0.25}
            metalness={0.15}
            emissive="#e8e8e0"
            emissiveIntensity={0.15}
            side={2}
          />
        </mesh>
      ))}
    </group>
  );
}

export function Muetze({ color, visible }: { color: string; visible: boolean }) {
  if (!visible) return null;
  return (
    <group position={[0, 1.68, 0]}>
      <mesh castShadow receiveShadow>
        <sphereGeometry args={[0.135, 32, 16, 0, Math.PI * 2, 0, Math.PI / 1.7]} />
        <meshStandardMaterial color={color} roughness={0.8} metalness={0.02} />
      </mesh>
      <mesh position={[0, -0.03, 0.1]} rotation={[0.35, 0, 0]} castShadow>
        <cylinderGeometry args={[0.1, 0.1, 0.015, 32, 1, false, 0, Math.PI]} />
        <meshStandardMaterial color={color} roughness={0.8} metalness={0.02} side={2} />
      </mesh>
    </group>
  );
}
