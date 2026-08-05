const skinColor = "#c9c7c2";

export function Mannequin() {
  return (
    <group>
      <mesh position={[0, 1.6, 0]} castShadow receiveShadow>
        <sphereGeometry args={[0.12, 32, 32]} />
        <meshStandardMaterial color={skinColor} roughness={0.5} metalness={0.05} />
      </mesh>

      <mesh position={[0, 1.44, 0]} castShadow receiveShadow>
        <cylinderGeometry args={[0.05, 0.06, 0.1, 16]} />
        <meshStandardMaterial color={skinColor} roughness={0.5} metalness={0.05} />
      </mesh>

      <mesh position={[0, 1.15, 0]} castShadow receiveShadow>
        <capsuleGeometry args={[0.19, 0.42, 8, 16]} />
        <meshStandardMaterial color={skinColor} roughness={0.5} metalness={0.05} />
      </mesh>

      <mesh position={[0, 0.85, 0]} castShadow receiveShadow>
        <capsuleGeometry args={[0.21, 0.12, 8, 16]} />
        <meshStandardMaterial color={skinColor} roughness={0.5} metalness={0.05} />
      </mesh>

      {[-1, 1].map((side) => (
        <mesh
          key={`arm-${side}`}
          position={[0.29 * side, 1.06, 0]}
          rotation={[0, 0, side * 0.12]}
          castShadow
          receiveShadow
        >
          <capsuleGeometry args={[0.055, 0.62, 8, 16]} />
          <meshStandardMaterial color={skinColor} roughness={0.5} metalness={0.05} />
        </mesh>
      ))}

      {[-1, 1].map((side) => (
        <mesh
          key={`leg-${side}`}
          position={[0.1 * side, 0.42, 0]}
          castShadow
          receiveShadow
        >
          <capsuleGeometry args={[0.095, 0.78, 8, 16]} />
          <meshStandardMaterial color={skinColor} roughness={0.5} metalness={0.05} />
        </mesh>
      ))}

      <mesh position={[0, 0.02, 0]} receiveShadow>
        <cylinderGeometry args={[0.32, 0.32, 0.03, 32]} />
        <meshStandardMaterial color="#8f8d89" roughness={0.7} metalness={0.1} />
      </mesh>
    </group>
  );
}
