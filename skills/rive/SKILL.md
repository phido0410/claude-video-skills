---
name: rive
description: Rive interactive animations (.riv files) on the web — @rive-app/webgl2 / canvas runtimes, React hooks (useRive, data binding hooks), state machines, data binding (view models), and @remotion/rive for video. Use when the user has a .riv file or asks for Rive, interactive mascots/icons, or state-machine driven animation.
---

# Rive

Checked 2026-10: @rive-app/canvas 2.45, @rive-app/react-canvas 4.37, @remotion/rive 4.0.

`.riv` files are made in the Rive editor (rive.app). Code can play and control them but cannot author them. Ask the user for the file, or use a community file from the Rive marketplace.

## Packages

| Need | Package |
|---|---|
| Vanilla JS, recommended | `@rive-app/webgl2` |
| Vanilla JS, Canvas2D | `@rive-app/canvas` (`@rive-app/canvas-lite` if no Text, Layouts, Scripting, Audio) |
| React | `@rive-app/react-webgl2` or `@rive-app/react-canvas` |
| Remotion | `@remotion/rive` |

## Vanilla

```js
import { Rive } from '@rive-app/webgl2'

const r = new Rive({
  src: '/hero.riv',
  canvas: document.getElementById('canvas'),
  stateMachines: 'State Machine 1',  // name from the editor
  autoplay: true,
  autoBind: true,                     // bind the default view model instance
  onLoad: () => r.resizeDrawingSurfaceToCanvas(),
})
window.addEventListener('resize', () => r.resizeDrawingSurfaceToCanvas())
// later: r.cleanup()
```

## Data binding (current way to drive a .riv)

State machine inputs (`r.stateMachineInputs(name)`, `.value`, `.fire()`) are **deprecated** in the runtime types. Use them only for old files without view models.

```js
const vmi = r.viewModelInstance          // needs autoBind: true
vmi.number('Progress').value = 0.75
vmi.string('Title').value = 'Hello'
vmi.boolean('Active').value = true
vmi.color('Accent').value = 0xFFFF5500    // ARGB
vmi.enum('Mood').value = 'Happy'
vmi.trigger('Jump').trigger()
vmi.number('Progress').on((e) => console.log(e.data))
```

## React

```jsx
import { useRive, useViewModel, useViewModelInstance,
  useViewModelInstanceNumber, useViewModelInstanceTrigger } from '@rive-app/react-canvas'

const { rive, RiveComponent } = useRive({ src: '/hero.riv', stateMachines: 'State Machine 1', autoplay: true })
const vm = useViewModel(rive)
const vmi = useViewModelInstance(vm, { useDefault: true, rive })
const { setValue: setProgress } = useViewModelInstanceNumber('Progress', vmi)
const { trigger: jump } = useViewModelInstanceTrigger('Jump', vmi)

return <RiveComponent style={{ width: 400, height: 400 }} onClick={jump} />
```

The container needs an explicit size; `RiveComponent` fills its parent.

## For video

In Remotion use `<RemotionRiveCanvas src="..." />` from `@remotion/rive` — it plays the file in sync with the current frame (check remotion-docs for its props). Interactive state machine logic that waits for clicks/hover will not run in a render; design the .riv with a timeline animation for video use.
