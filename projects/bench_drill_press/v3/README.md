# Bench drill press v3: fewer, smarter parts

Status: **v3 model complete and verified in software. Not printed yet.**
Measure the parts in "Before you print" first.

Design: [../design_v3.md](../design_v3.md). Build plan: [../plan_v3.md](../plan_v3.md).
Interactive 3D viewer: `drill_press_v3.html`. You can pull it apart, cut through it and measure, and switch between pose and tool.

## What changed from v2

| | v2 | v3 |
|---|---|---|
| Printed parts | ~25 | **9** (+ 1 test coupon) |
| Screws | ~20 | **8** (1 × M5, 7 × M3) |
| Guide | 4 printed sleeves with squeeze screws | **Preloaded V-slide**: V and flat-pad seats plus printed spring gibs, no gap, wear takes itself up |
| Feed | Side lever, pushes off-centre (twist) | **Rack and pinion on the centreline**, 5.7 : 1 |
| Frame | Base + bridge + spine + 8 screws | **One printed C-frame** |
| Tool mount | Dovetail, key, 3 holders, lock knob | **43 mm Euro-collar ring** (775 direct) + 555 / iron sleeves |
| Return | Kickstand spring on the lever tail | Kickstand spring on a **printed gear slider**; resting on its ledge is the top stop |
| Depth stop | Rod collar, thumbwheel, M5 | **Ring on the pinion shaft with a 2 mm scale** |

Size: 140 × 180 mm base, **248 mm tall**. Clearance under the tool is 40 mm, and plunge travel is 40 mm.

## How the slide works

The feed always tips the head the same way, front up and back down, because the rack sits behind the rods. So the **rigid seats** are placed where that tipping presses:
- At the top: a 90° V on the left rod and a flat pad on the right rod, both **in front** of the rods.
- At the bottom: the same pair, **behind** the rods.

Opposite each seat, a thin printed blade (gib) presses the rod in with about 3.5 N. Drilling and insert loads go into rigid plastic, and the springy blades only remove play.

## Before you print: measure these

Each of these is marked `UNVERIFIED` in `params.scad`. Measure yours, change the value, and run `bash check.sh`.

| What | Parameter | Model value |
|---|---|---|
| 775 body Ø / length / front boss | `m775_d`, `m775_len`, `m775_boss` | 42 / 67 / Ø17.5 × 4.5 |
| 555 body Ø / length / boss | `m555_d`, `m555_len`, `m555_boss` | 35.8 / 57 / Ø13 × 3 |
| Chuck Ø / length; bit stick-out | `chuck_d`, `chuck_len`, `bit_stickout` | 22 / 40; 20 |
| Pen iron handle Ø | `iron_d` | 22 |
| Iron hot zone, measured from the tip | `iron_hot_len` | 60 |
| Kickstand spring: length incl. hooks, Ø | `ks_L0`, `ks_od` | 75, 12 |
| Spring rate: hang 1 kg, stretch in mm → k = 9.81 / stretch | `ks_k` | 2.0 N/mm |
| Spring pre-tension (the weight at which it just starts to open) | `ks_T0` | 10 N |
| Head weight (head + motor) | `head_mass` | 0.55 kg |
| Heat-set insert hole sizes | `m3_insert`, `m5_insert` | Ø4.0, Ø6.4 |

**About the iron's hot zone.** The design fits a 60 mm hot zone with 3 mm to spare. If your iron's hot section is longer, `check.sh` fails, and the fix is a trade-off: less clearance under the iron or a smaller air gap.

**Print `stl/Preload_coupon.stl` first.** It has three test cells, marked by 1, 2 or 3 notches, each with the head's V seat and gib at a preload gap of −0.2, 0 or +0.2 mm. Slide each onto a rod **before cutting it**. Keep the cell with no play that still slides by hand, then adjust `gib_preload` until `gib_gap` matches that cell.

## Print list (PLA, Kobra 2 Neo, no supports)

| Part | Orientation (already applied in the STLs) | Notes |
|---|---|---|
| C-frame | As modelled, base on the bed | 248 mm tall. 4 walls, 25 % infill |
| Head | Upright | 5 walls, 40 %. The rack teeth print like a thread |
| Pinion shaft | Upright, hub end down | 100 % infill. 120 mm tall and thin: use a brim |
| Main pinion | Flat | 100 % |
| Spring slider | On its side | 100 % |
| Handle (3 spokes) | Flat | 4 walls, 30 % |
| Depth-stop ring | Ring down | 100 % |
| 555 sleeve / iron sleeve | Upside down (tabs on the bed) | The iron sleeve is PLA: treat it as replaceable |

## Hardware

| Item | Qty | Use |
|---|---|---|
| Ø8 × 500 mm chrome rod (Robu), **cut to 2 × 245 mm** | 1 | Guide rods |
| Bike kickstand spring | 1 | Head return |
| M5 + insert | 1 | 43 mm ring clamp |
| M3 grub/set screw + insert | 2 | Rod retention in the top arms |
| M3 × 10, thread-forming into Ø2.6 pilots | 4 | Gib adjusters (re-tighten if the slide develops play) |
| M3 × 12, thread-forming | 1 | Depth-stop ring clamp |

## Assembly order

1. Fit the M5 insert in the ring ear and M3 inserts in the arm bosses. Run the 4 gib adjusters in until they just touch the blades.
2. Put the **spring slider** and the **main pinion** into the column through the rear window. Hook the spring onto the anchor peg at the bottom and onto the slider's bar.
3. Push the **pinion shaft** in from the +x side through the right wall, the main pinion's hex and the left wall, until its collar meets the right wall. Its built-in spring pinion meshes with the slider.
4. Put the **head** between the arms with its rack in the window, then drop the **rods** through the arm bosses, the head and into the base sockets. Lock them with the 2 grub screws.
5. Press the **handle** onto the +x hex. Slide the **stop ring** onto the −x end until its sleeve touches the wall, set the depth on the scale against the stop pin, and clamp it.
6. Tools: the 775 goes straight into the ring. The 555 and iron go in their sleeves, with the sleeve split lined up with the ring's split. Set the height and clamp the M5.

## Tuning

- **Slide play:** turn the gib adjusters in a little. **Stiff slide:** back them off.
- **Head doesn't return fully:** the spring is weaker than modelled. Measure `ks_k` and `ks_T0`, update them, and `check.sh` will move the anchor peg. Reprint the C-frame only if the anchor moves.
- **Bits snapping:** check for play first, then feed more slowly. At 5.7 : 1 the handle is sensitive.

## Check / regenerate

```
bash check.sh                                                       # 7 poses × tools: clash/fit checks + all asserts
python3 ../../../common/skills/openscad/scripts/asm.py drill_press_v3.scad --print
python3 ../../../common/tools/validate_stl.py stl/*.stl
```

Known validator flags, all reviewed and accepted:
- **C-frame:** knife edges where the rod holes exit the 45° arms.
- **Pinion shaft:** the module-1 gear tooth tips.
- **Sleeves and depth-stop ring:** split and counterbore corners.
