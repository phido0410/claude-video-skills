---
name: motion-canvas
description: Motion Canvas — code-driven 2D explainer/animated videos in TypeScript using generator scenes (makeScene2D, yield*, refs, signals, all/chain/sequence/waitUntil), a live editor, and rendering to image sequence or MP4 (@motion-canvas/ffmpeg). Use when the user asks for Motion Canvas, or for a voiceover-synced explainer animation built outside Remotion.
---

# Motion Canvas

Checked 2026-10: @motion-canvas/core, /2d, /ffmpeg 3.17. Needs Node 16+.

Remotion vs Motion Canvas: Remotion = React, frame → UI, scales to data-driven/templated videos and server rendering. Motion Canvas = imperative timeline (`yield*` one step after another) with an editor for timing to a voiceover. Pick one per video; do not mix.

## Setup

```bash
npm init @motion-canvas@latest   # name, TypeScript, choose "Video (FFmpeg)" exporter
npm install
npm run serve                    # editor at http://localhost:9000
```

```
src/project.ts        # makeProject({ scenes: [...] })
src/scenes/*.tsx      # one scene per file
```

```ts
// src/project.ts
import {makeProject} from '@motion-canvas/core';
import intro from './scenes/intro?scene';   // ?scene suffix is required
export default makeProject({scenes: [intro]});
```

## Scene

```tsx
import {Circle, Rect, Txt, makeScene2D} from '@motion-canvas/2d';
import {all, chain, createRef, easeInOutCubic, sequence, waitFor, waitUntil} from '@motion-canvas/core';

export default makeScene2D(function* (view) {
  const circle = createRef<Circle>();
  view.add(<Circle ref={circle} x={-300} size={240} fill="#e13238" />);

  yield* all(                                   // in parallel, wait for all
    circle().position.x(300, 1).to(-300, 1),     // tween: prop(value, seconds), chain with .to()
    circle().fill('#e6a700', 1).to('#e13238', 1),
  );
  yield* waitUntil('title');                    // named time event, dragged in the editor timeline
  yield* circle().scale(2, 0.6, easeInOutCubic);
});
```

- Coordinates: origin at the center of the view; `x`, `y`, `size`, `width`, `height`, `rotation`, `scale`, `opacity`, `fill`, `stroke`, `lineWidth`.
- Components: `Rect` (`radius` for rounded), `Circle`, `Line` / `Spline` (`points`, `end` for draw-on), `Txt`, `Img`, `Video`, `Layout` (flexbox: `layout direction gap`), `Code`, `Latex`.
- A prop called with a value sets it; with `(value, seconds[, ease])` it tweens and must be `yield*`ed; with no args it reads.

## Flow

| Call | Effect |
|---|---|
| `all(...t)` | run together, wait for all |
| `any(...t)` | run together, wait for first |
| `chain(...t)` | one after another |
| `sequence(0.2, ...t)` | start each 0.2 s after the previous (no waiting) |
| `delay(0.5, t)` | start after 0.5 s |
| `loop(3, () => t)` | repeat |
| `waitFor(1.5)` | pause 1.5 s |
| `waitUntil('event')` | pause until the editor's named event — use this for voiceover sync |
| `useDuration('event')` | length of a named event, as a tween duration |

## Render

- Editor → Rendering panel: resolution, frame rate (24/30/60), range, exporter. Click **RENDER**.
- Output lands in `/output`. Default exporter writes an image sequence; for MP4 with audio add the FFmpeg exporter:

```bash
npm install --save @motion-canvas/ffmpeg
```

```ts
// vite.config.ts
import {defineConfig} from 'vite';
import motionCanvas from '@motion-canvas/vite-plugin';
import ffmpeg from '@motion-canvas/ffmpeg';
export default defineConfig({plugins: [motionCanvas(), ffmpeg()]});
```

Then pick **Video (FFmpeg)** in Video Settings.

- Resolution changes do not scale the layout; decide the final size (e.g. 1920×1080 or 1080×1920) before laying out.
