---
name: howler
description: Howler.js web audio playback — Howl sounds, sprites, fades, rate/seek, stereo/spatial, global volume/mute, autoplay unlock, syncing visuals to audio. Use for sound in interactive web pages (UI sounds, background music, interactive demos). For rendered video (Remotion, Motion Canvas) use the framework's own audio instead.
---

# Howler.js

Checked 2026-10: howler 2.2.

```bash
npm i howler
```

```js
import { Howl, Howler } from 'howler'

const music = new Howl({
  src: ['/audio/bg.webm', '/audio/bg.mp3'],   // first playable format wins: webm, then mp3 fallback
  loop: true,
  volume: 0.4,
  html5: true,                                 // stream long files instead of decoding them fully
})

const sfx = new Howl({
  src: ['/audio/sfx.webm', '/audio/sfx.mp3'],
  sprite: { click: [0, 120], whoosh: [500, 900], ding: [1600, 700] }, // name: [offsetMs, durationMs]
})

const id = music.play()                 // returns a sound id
music.fade(0, 0.4, 1500, id)            // from, to, ms, id
sfx.play('whoosh')
music.rate(1.25)                        // 0.5 – 4.0
music.seek()                            // current position in seconds; music.seek(30) to jump
sfx.stereo(-0.5)                        // -1 left … 1 right
Howler.volume(0.8); Howler.mute(true); Howler.stop()
```

## Events and autoplay

Browsers block sound until a user gesture. Start playback from a click/tap, and recover from a blocked play:

```js
const s = new Howl({
  src: ['/a.webm', '/a.mp3'],
  onplayerror: () => s.once('unlock', () => s.play()),
})
```

Other events: `onload`, `onloaderror`, `onend`, `onfade`; or `s.on('end', fn)`.

## Sync visuals to audio

Read `sound.seek()` in `requestAnimationFrame` and seek the animation to it, e.g. `tl.seek(sound.seek())` (GSAP, seconds) or `tl.seek(sound.seek() * 1000)` (Anime.js, ms). Do not run the animation on its own clock next to the audio; they drift.

## For video

Remotion and Motion Canvas render offline, frame by frame — Howler does not play into the output file. Use Remotion `<Audio>` / `@remotion/media` (see remotion-markup/audio.md, sfx.md) or Motion Canvas project audio. Howler is only for the interactive web version of a piece.
