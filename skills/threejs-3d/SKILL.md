---
name: threejs-3d
description: 3D with Three.js, React Three Fiber (R3F), Drei helpers, Rapier physics (@react-three/rapier) and postprocessing effects (@react-three/postprocessing). Use when building 3D scenes for web or video — models (GLTF), lights, cameras, environment maps, physics, bloom/vignette/depth-of-field. Inside Remotion, also follow remotion-markup/3d.md.
---

# Three.js 3D stack

Checked 2026-10: three 0.186, @react-three/fiber 9.8, @react-three/drei 10.7, @react-three/rapier 2.2, @react-three/postprocessing 3.2 (+ postprocessing 6.39). Fiber 9 / Drei 10 / Rapier 2 / postprocessing 3 need React 19 (fiber 9.8 peer: react >=19 <19.4).

```bash
npm i three @react-three/fiber @react-three/drei
npm i @react-three/rapier                         # physics
npm i @react-three/postprocessing postprocessing  # effects
npm i -D @types/three
```

## Base scene (web)

```tsx
import { useRef, Suspense } from 'react'
import * as THREE from 'three'
import { Canvas, useFrame } from '@react-three/fiber'
import { OrbitControls, Environment, ContactShadows } from '@react-three/drei'

function Box() {
  const ref = useRef<THREE.Mesh>(null!)
  useFrame((_, delta) => { ref.current.rotation.y += delta }) // mutate refs, never setState per frame
  return (
    <mesh ref={ref} castShadow>
      <boxGeometry />
      <meshStandardMaterial color="#4a9eff" />
    </mesh>
  )
}

<Canvas camera={{ position: [3, 2, 5], fov: 45 }} dpr={[1, 2]} shadows>
  <ambientLight intensity={0.3} />
  <directionalLight position={[5, 5, 5]} castShadow />
  <Suspense fallback={null}>
    <Box />
    <Environment preset="city" />
  </Suspense>
  <ContactShadows position={[0, -0.5, 0]} opacity={0.5} blur={2} />
  <OrbitControls />
</Canvas>
```

Rules:
- Anything async (useGLTF, useTexture, Environment, Text fonts, Physics WASM) sits under `<Suspense>`.
- `useGLTF.preload(url)` at module level for models used on first paint.
- Keep scenes around 1–10 units; huge/small scales break shadows and controls.
- `MeshStandardMaterial` needs light or an `<Environment>`; with neither, it renders black.

## Drei (pick what is needed)

- Camera/controls: `OrbitControls`, `CameraControls`, `PerspectiveCamera makeDefault`
- Assets: `useGLTF`, `useTexture`, `Environment` (presets: apartment, city, dawn, forest, lobby, night, park, studio, sunset, warehouse), `Center`, `Bounds`
- Staging: `ContactShadows`, `AccumulativeShadows`, `Stage`, `Float`, `Sparkles`, `Stars`, `Cloud`
- Materials: `MeshTransmissionMaterial` (glass), `MeshReflectorMaterial` (reflective floor)
- Text: `Text` (SDF, any font URL), `Text3D` (needs typeface JSON), `Html` (DOM overlay)

## Rapier physics

```tsx
import { Physics, RigidBody, CuboidCollider, type RapierRigidBody } from '@react-three/rapier'

<Suspense>
  <Physics gravity={[0, -9.81, 0]} /* debug */>
    <RigidBody colliders="hull" restitution={0.6} ref={bodyRef}>
      <mesh><torusGeometry /><meshStandardMaterial /></mesh>
    </RigidBody>
    <RigidBody type="fixed">
      <CuboidCollider args={[10, 0.1, 10]} /> {/* half extents */}
    </RigidBody>
  </Physics>
</Suspense>
// bodyRef.current?.applyImpulse({ x: 0, y: 5, z: 0 }, true)
```

- `colliders`: `"cuboid"` (default), `"ball"`, `"hull"`, `"trimesh"`, `false` (add collider components yourself).
- `type`: `"dynamic"` (default), `"fixed"`, `"kinematicPosition"`, `"kinematicVelocity"`.
- `timeStep` defaults to a fixed 1/60. `timeStep="vary"` is not deterministic. Manual stepping: `useRapier().step(1 / 60)`.
- `debug` on `<Physics>` draws colliders.

## Postprocessing

```tsx
import { EffectComposer, Bloom, Vignette, DepthOfField, Noise } from '@react-three/postprocessing'

<EffectComposer>{/* last child of <Canvas> */}
  <Bloom luminanceThreshold={0.9} intensity={1.2} mipmapBlur />
  <Vignette offset={0.1} darkness={0.9} />
</EffectComposer>
```

- Bloom only catches pixels above `luminanceThreshold`. To make one object glow: `emissive` color + `emissiveIntensity` > 1 + `toneMapped={false}` on its material.
- Each effect costs a full-screen pass; 2–4 effects is plenty.

## For video

Remotion (see remotion-markup/3d.md): `<ThreeCanvas width height>` from `@remotion/three`; no `useFrame`; every motion comes from `useCurrentFrame()`. Additionally:
- No `OrbitControls` — move the camera from `frame` (`interpolate` / `spring`).
- Drei helpers that animate on their own clock (`Float`, `Sparkles`, `Stars`, `Cloud`, `MeshWobbleMaterial`) flicker in renders. Leave them out or reproduce the motion from `frame`.
- Physics: Remotion renders frames out of order across tabs, so a live simulation cannot match. Bake it: init `@dimforge/rapier3d-compat` (the engine under @react-three/rapier) once, `world.step()` with `timestep = 1 / fps` for every frame, store each body's position + rotation per frame, then render the transforms at index `frame`.

Outside Remotion (screen-recorded, GSAP-driven): `useFrame` is fine; drive time from a timeline (`tl.time()`) instead of `delta` when the shot must be repeatable.
