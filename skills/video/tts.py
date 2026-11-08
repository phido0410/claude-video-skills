# /// script
# requires-python = ">=3.10"
# dependencies = ["edge-tts>=7.3"]
# ///
"""Voiceover with the user's fixed voice (voice.json): one mp3 per scene.

uv run ~/.claude/skills/video/tts.py SCENES.json OUT_DIR [--style huong-dan|dien-thuyet|mo-ta]
SCENES.json: [{"id": "01-intro", "text": "..."}, ...]  ->  OUT_DIR/01-intro.mp3, ...
"""
import argparse
import asyncio
import json
import pathlib

import edge_tts

CONFIG = json.loads(pathlib.Path(__file__).with_name("voice.json").read_text())


async def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("scenes")
    p.add_argument("out")
    p.add_argument("--style", default=CONFIG["default_style"], choices=CONFIG["styles"])
    args = p.parse_args()

    style = CONFIG["styles"][args.style]
    scenes = json.loads(pathlib.Path(args.scenes).read_text(encoding="utf-8"))
    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    for scene in scenes:
        dest = out / f"{scene['id']}.mp3"
        tts = edge_tts.Communicate(scene["text"], CONFIG["voice"], rate=style["rate"], pitch=style["pitch"])
        await tts.save(str(dest))
        assert dest.stat().st_size > 0, f"no audio for scene {scene['id']}"
        print(dest)


asyncio.run(main())
