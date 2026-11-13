# Bench drill press (fully 3D printed, PLA)

Status: **v1 model complete and verified in software. Not printed yet.**
Measure the parts in "Before you print" first.

A compact press, about 140 × 160 mm on the bench and 220 mm tall. It has a
swappable head for:
- **PCB drilling**: a 555 or 775 motor with chuck, 0.6–1.0 mm carbide bits
- **Heat-set inserts**: a 60 W pen soldering iron

Design: [design.md](design.md). Build plan: [plan.md](plan.md).
Interactive 3D viewer: open `bench_drill_press.html` in a browser. You can
pull it apart, cut through it and measure, and switch between pose and tool.

## Before you print: measure these

The model uses typical sizes, marked `UNVERIFIED` in `params.scad`. Measure
yours, update the value, and run `bash check.sh`.

| What | Parameter | Model value |
|---|---|---|
| 775 body diameter, length | `m775_d`, `m775_len` | 42, 67 |
| 775 face screw size, spacing | `m775_screw` | M4, 29 |
| 775 front bearing boss Ø, height | `m775_boss` | 17.5, 4.5 |
| 555 body diameter, length | `m555_d`, `m555_len` | 35.8, 57 |
| 555 face screw size, spacing | `m555_screw` | M3, 25 |
| Chuck Ø, length; bit stick-out | `chuck_d`, `chuck_len`, `bit_stickout` | 22, 40, 20 |
| Iron handle Ø where it's gripped | `iron_d` (the clamp takes 18–26) | 22 |
| Iron hot zone length, measured from the tip | `iron_hot_len` | 60 |
| Your heat-set insert hole sizes | `m3_insert`, `m5_insert` | Ø4.0, Ø6.4 |

**Print `stl/Sleeve_bore_test_set.stl` first.** It has six sleeves with bores
of 7.9 to 8.4 mm, marked by 1–6 notches on the rim. Keep the one that slides
on your rod with no wobble, and set `sleeve_bore` to its size.

## Print list (PLA, Kobra 2 Neo)

All STLs in `stl/` are already in print orientation, flat on the bed. No
supports are needed.

| Part | Qty | Notes |
|---|---|---|
| Base | 1 | 4 walls, 30 % infill |
| Top bridge | 1 | Prints upside down. 4 walls, 40 % |
| Spine | 1 | Prints flat. 4 walls, 40 % |
| Carriage | 1 | 5 walls, 40 % |
| Sleeve 0–3 | 4 | 100 % infill. Use the bore from the test set |
| Lever | 1 | Prints flat. 5 walls, 50 % |
| Counterweight lid | 1 | |
| Depth-stop collar, thumbwheel | 1 + 1 | |
| Holder lock knob | 1 | |
| 775 motor holder / 555 motor holder | 1 each | Prints on its back. 5 walls, 40 % |
| Iron holder + iron clamp strap | 1 + 1 | Prints on its back |

## Hardware

Approved by you on 2026-11-13, except the line marked **NEEDS OK**.

| Item | Qty | Where |
|---|---|---|
| Ø8 mm chrome rod, 500 mm (Robu) → **cut to 2 × 216 mm** | 1 | Column. Cut length comes from `rod_len` |
| M8 × 30 bolt + nyloc nut | 1 | Lever pivot |
| M5 × 30 + M5 insert | 1 | Holder lock (knob on the head) |
| M5 × 35 + M5 insert | 1 | Lever–carriage link pin |
| M5 × 20 + M5 insert | 1 | Depth-stop screw (thumbwheel on the head) |
| M3 × 20 + insert | 4 | Rod clamps (base 2, bridge 2) |
| M3 × 12 + insert | 9 | Spine (4), sleeve squeeze screws (4), stop collar (1) |
| M3 × 30 + insert | 2 | Iron clamp strap. **NEEDS OK**: brings M3 to 15, above the ~12 approved |
| Kit extension spring 7.93 × 44.4 | 1–3 | Lever return, on the printed pegs |
| Motor face screws | 2 + 2 | Usually supplied with the motor |

## Assembly order

1. Fit inserts in every part: base and bridge rear faces, clamp jaws, carriage
   ears, rear face and right side, collar, iron block.
2. Push the rods into the base sockets and tighten the base clamp screws. They
   go in from the base's rear face.
3. Slide the depth-stop collar onto the left rod. Thread the M5 × 20 up through
   it, with the thumbwheel pressed on its head.
4. Press the sleeves into the carriage, slide the carriage onto the rods, and
   tighten the four squeeze screws from the back until there's no wobble but
   it still slides.
5. Put the top bridge on the rods and tighten its clamp screws from the rear.
   Bolt the spine to the rear faces of the base and bridge (4 × M3 from
   behind).
6. Lever: M8 bolt from the left through the ear and lever, nyloc on the right.
   Push the M5 link pin through the lever slot into the carriage's side
   insert. Leave it slightly loose so it can turn.
7. Hook a spring between the middle lever peg and the bridge peg above it.
   Add more springs or counterweight until the head comes back up by itself.
8. Slide a tool holder into the dovetail from below. Set its height and lock
   it with the rear knob.

## Known risks

- **The return springs may be too weak** [Guessing; the kit's spring rate isn't
  published]. Lifting the 775 head takes about 0.22 J, which is at the limit
  for 2–3 kit springs. Fix: add springs (there are 3 pegs) or put weight in
  the lever's counterweight pocket.
- **The sleeves are held only by the squeeze screws.** If they creep, a drop
  of glue on the outside fixes them in place.
- **PLA near the iron:** the clamp grips only the handle, with ≥ 10 mm of air
  between the PLA and the hot zone. If the handle itself gets above about
  50 °C, reprint the iron holder in PETG.
- **Depth stop:** a collar clamped by friction. Tighten its M3 firmly.

## Check / regenerate

```
bash check.sh          # all poses × all tools: 30 clash/fit checks each, plus the asserts in params.scad
python3 ../../common/skills/openscad/scripts/asm.py bench_drill_press.scad --print   # print files
python3 ../../common/tools/validate_stl.py stl/*.stl     # printability report
```

Poses and tools are variants: `up`, `mid` and `down` use the 775; `up_555`
and `down_555` use the 555; `up_iron` and `down_iron` use the iron.
