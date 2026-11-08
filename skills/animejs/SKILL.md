---
name: animejs
description: Anime.js v4 animation (animate, createTimeline, stagger, svg.createDrawable / morphTo / createMotionPath, createScope, utils). Use when the user asks for Anime.js / animejs, or for lightweight JS animation of DOM, SVG, CSS variables or plain JS objects. v4's API differs from v3 — there is no anime() default export.
---

# Anime.js v4

Checked 2026-10: animejs 4.5.

```bash
npm i animejs
```

```js
import { animate, createTimeline, stagger, svg, utils, createScope } from 'animejs'
```

## v3 → v4 (old tutorials use v3)

| v3 | v4 |
|---|---|
| `anime({ targets, ... })` | `animate(targets, { ... })` |
| `easing: 'easeOutQuad'` | `ease: 'outQuad'` (`'inOutExpo'`, `'inOut(3)'`, ...) |
| `anime.timeline()` | `createTimeline()` |
| `direction: 'alternate'` | `alternate: true` |
| `update`, `complete`, `begin` | `onUpdate`, `onComplete`, `onBegin` |

Durations and delays are **milliseconds** (GSAP uses seconds).

## animate

```js
animate('.square', {
  x: 320,                       // shorthand for translateX
  rotate: { from: -180 },
  opacity: [0, 1],              // [from, to]
  duration: 1250,
  delay: stagger(65, { from: 'center' }),
  ease: 'inOutQuint',
  loop: true,
  alternate: true,
})
```

Targets: CSS selector, element(s), or a plain object (`animate(obj, { value: 100, onUpdate: () => draw(obj.value) })`).

## Timeline

```js
const tl = createTimeline({ defaults: { duration: 600, ease: 'outExpo' } })
tl.add('.title', { opacity: [0, 1], y: [40, 0] })
  .add('.sub',   { opacity: [0, 1] }, '-=300')       // 300 ms before previous end
  .add('.dot',   { scale: [0, 1], delay: stagger(80) }, '<<') // with previous start
```

Positions: `100` absolute ms · `'+=100'` / `'-=100'` relative to previous end · `'<'` previous end · `'<<'` previous start · `'<<+=250'` · `'Label'` (set with `tl.label('Label')`) · `stagger(10)`.

## SVG

```js
animate(svg.createDrawable('.line'), { draw: ['0 0', '0 1'], duration: 2000 }) // stroke draw-on, values 0–1 "start end"
animate('#shapeA', { d: svg.morphTo('#shapeB'), duration: 800 })                // morph path A into B
animate('.car', { ...svg.createMotionPath('#road'), duration: 4000 })            // follow a path (x, y, rotate)
```

## Playback / scrubbing

`autoplay: false`, then `.play()`, `.pause()`, `.restart()`, `.reverse()`, `.seek(ms)`, `.complete()`, `.cancel()`, `.revert()` (undo all inline styles).

## React

```jsx
const root = useRef(null)
useEffect(() => {
  const scope = createScope({ root }).add(() => {
    animate('.box', { x: 200 })     // selectors are scoped to root
  })
  return () => scope.revert()
}, [])
```

## For video

Anime.js runs on its own clock. Inside Remotion, build it paused and seek per frame — never let it autoplay:

```jsx
const frame = useCurrentFrame()
const { fps } = useVideoConfig()
const tl = useRef(null)
useLayoutEffect(() => {
  tl.current = createTimeline({ autoplay: false }).add('.title', { y: [40, 0], opacity: [0, 1] })
  return () => tl.current.revert()
}, [])
useLayoutEffect(() => { tl.current.seek((frame / fps) * 1000) }, [frame, fps])
```

Prefer Remotion's own `interpolate` / `spring` for simple moves; reach for Anime.js when its SVG helpers (draw, morph, motion path) or staggers save real work.
