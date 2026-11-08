---
name: svg-design
description: SVG asset pipeline — Satori (HTML/JSX + CSS → SVG, then PNG via resvg or sharp) for title cards, thumbnails, OG images, stills; and SVGO v4 (optimize/minify SVGs, CLI + config) without breaking SVGs that will be animated. Use when generating images from markup, making video thumbnails/stills, or cleaning SVGs before animating them with GSAP / Anime.js / Remotion.
---

# SVG design: Satori + SVGO

Checked 2026-10: satori 0.63, @resvg/resvg-js 2.6, svgo 4.1.

## Satori — markup → SVG

```bash
npm i satori @resvg/resvg-js
```

```js
import satori from 'satori'
import { Resvg } from '@resvg/resvg-js'
import { readFile, writeFile } from 'node:fs/promises'

const font = await readFile('./Inter-Bold.ttf')            // TTF, OTF, WOFF or WOFF2
const svg = await satori(
  <div style={{ display: 'flex', width: '100%', height: '100%', alignItems: 'center',
                justifyContent: 'center', background: '#0b1020', color: 'white', fontSize: 96 }}>
    Đủ 20/20
  </div>,
  { width: 1920, height: 1080, fonts: [{ name: 'Inter', data: font, weight: 700, style: 'normal' }] },
)
const png = new Resvg(svg, { fitTo: { mode: 'width', value: 1920 } }).render().asPng()
await writeFile('title.png', png)
```

- Without JSX/React, pass plain objects: `{ type: 'div', props: { style: {...}, children: '...' } }`.
- Fonts are mandatory whenever there is text; Vietnamese needs a font that has the glyphs (Inter, Be Vietnam Pro, Noto Sans).
- Layout: Flexbox, Grid (no subgrid/masonry) and block. It is a CSS subset — no JS, no animations, no external stylesheets; style inline.
- Images: `<img src>` with an absolute URL or data URI, plus explicit `width`/`height`.
- Text becomes `<path>` by default (portable, not selectable); `embedFont: false` keeps `<text>`.
- Emoji: `graphemeImages` or `loadAdditionalAsset` to supply images/fonts for missing segments.
- PNG alternative: `sharp(Buffer.from(svg)).png()`.

## SVGO v4 — optimize

```bash
npx svgo in.svg -o out.svg
npx svgo -f ./icons -o ./icons-min
```

```js
// svgo.config.mjs
export default {
  multipass: true,
  plugins: [
    { name: 'preset-default', params: { overrides: {
      // keep these when the SVG will be animated or styled by id/class:
      cleanupIds: false,          // would rename/remove ids your code targets
      collapseGroups: false,      // would flatten <g> you animate as a unit
      mergePaths: false,          // would merge paths you animate separately
      convertShapeToPath: false,  // would turn <circle>/<rect> into <path> (no more r, cx, width)
    } } },
    'prefixIds',                  // unique ids when several SVGs are inlined on one page
  ],
}
```

- v4 changes: `removeViewBox` and `removeTitle` are no longer in preset-default (add them by name if wanted; keep the viewBox for scaling). `removeScriptElement` → `removeScripts`. Only named exports: `import { optimize } from 'svgo'`; browser build is `svgo/browser`.
- Node API: `const { data } = optimize(svgString, { multipass: true, plugins: [...] })`.
- For static icons, plain `preset-default` is fine; the overrides above only matter for animated or scripted SVGs.
- After optimizing an SVG for animation, check that every selector the animation code uses still exists in the output.
