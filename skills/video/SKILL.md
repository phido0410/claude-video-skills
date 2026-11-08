---
name: video
description: Entry point for any video job (làm video, dựng video, video ngắn, reels, TikTok, YouTube, intro, explainer, motion graphics, animated slides, render mp4). Load this FIRST whenever the user asks to make, edit or render a video, in any project — it holds the user's standard 20-library toolset, which skill to load for each part, and the workflow.
---

# Video — standard toolset and workflow

The user's standard set for every video. Pick from it first. Load the listed skill before writing code for that part.

| Layer | Library | Skill to load |
|---|---|---|
| Build 2D (engine) | Remotion — default | `remotion-best-practices` (routes to the other `remotion-*`) |
| | Motion Canvas — only when asked, or for a voiceover-timed explainer | `motion-canvas` |
| Animate | GSAP (timelines, SVG, text) | `gsap-*` |
| | Anime.js (SVG draw / morph / motion path, staggers) | `animejs` |
| | Motion (springs, UI-style motion) | `motion` |
| | Lottie (ready-made .json animations) | `remotion-markup` → lottie.md |
| | Rive (.riv files from the user) | `rive` |
| Build 3D | Three.js, R3F, Drei, Rapier, postprocessing | `threejs-3d` + `remotion-markup` → 3d.md |
| Design | Satori (title cards, thumbnails, stills), SVGO (clean SVGs) | `svg-design` |
| Sound / render | Mediabunny (media decode/inspect), FFmpeg | `remotion-multimedia`, `remotion-markup` → ffmpeg.md |
| | Howler — interactive web version only, never for the rendered file | `howler` |
| Voiceover | Fixed voice via edge-tts — see below | — |

## Voiceover (fixed voice)

The user chose one voice for every video: Vietnamese, male, northern accent. Voice and styles live in `voice.json` next to this file — read them from there, never hardcode.

Pick the style from the video type:

| Style | For |
|---|---|
| `huong-dan` | tutorials, how-tos, step-by-step (default) |
| `dien-thuyet` | talks, storytelling, inspirational — slower, deeper |
| `mo-ta` | descriptions, product intros, promos — a bit faster, brighter |

```bash
# scenes.json: [{"id": "01-intro", "text": "..."}, ...]
uv run ~/.claude/skills/video/tts.py scenes.json public/voiceover/<composition-id> --style huong-dan
```

- Remotion: follow `remotion-markup/voiceover.md` for `calculateMetadata` and audio playback, but skip its ElevenLabs generation step — this script replaces it (and `eleven_multilingual_v2` has no Vietnamese anyway).
- The voice cannot act emotions; tone comes from the style plus the script. Write lines as spoken Vietnamese: short sentences, commas and "..." where a pause is wanted. If a number, abbreviation or English word is misread, rewrite it as it should sound.
- To change the voice or tune a style, edit `voice.json` only.
- edge-tts uses Edge's read-aloud service without an official API. If it stops working, switch to Azure AI Speech (same voice name, needs the user's key and region); ask the user before setting that up.

## Workflow

1. **Brief.** Ask only for what is missing: content/script, aspect (9:16 = 1080×1920, 16:9 = 1920×1080, 1:1 = 1080×1080), length, voiceover (fixed voice — only ask which style if the video type is unclear) / music / captions, language. Default 30 fps.
2. **Plan.** Name the scenes and which libraries each one uses. Use the fewest libraries that do the job well; the set is a menu, not a checklist.
3. **Project.** One new folder per video. Scaffold with the engine's skill (Remotion: `remotion-create`). Install only the libraries the plan uses, inside that project (`npm i ...` / `npx remotion add @remotion/...`). Never install globally.
4. **Build.** Every motion is driven by the frame: `useCurrentFrame()` in Remotion; GSAP / Anime.js timelines created paused and seeked per frame; no `useFrame`, no free-running clocks, no live physics (bake it). Vietnamese text needs fonts with Vietnamese glyphs (Be Vietnam Pro, Inter, Noto Sans).
5. **Preview.** Open the studio/editor and show the user before the final render.
6. **Render.** Follow the engine's render skill. Check the output file (duration, resolution, audio present) before reporting done.
