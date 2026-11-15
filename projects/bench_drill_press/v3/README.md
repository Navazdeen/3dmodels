# Bench drill press v3.1: split frame, steel axle, rod-collar depth stop

Status: **v3.1 model complete and verified in software. Not printed yet.**
Measure the parts in "Before you print" first.

Design: [../design_v3.md](../design_v3.md), amended by [../design_v3_1.md](../design_v3_1.md).
Build plans: [../plan_v3.md](../plan_v3.md), [../plan_v3_1.md](../plan_v3_1.md).
Interactive 3D viewer: `drill_press_v3.html`. You can pull it apart, cut through it and measure, and switch between pose and tool.

## What changed from v3

| | v3 | v3.1 |
|---|---|---|
| Frame | One 248 mm C-frame, about a 20 h print, bending load across the layers | **Base + column + rear cover + top arm**. Each prints in the orientation its load wants; the tallest print is 70 mm (the head) |
| Joints | none | Keyed pockets (0.2 mm clearance) locate the parts, M5s only clamp, so the rods stay parallel without hand-fitting |
| Pinion shaft | Printed, twisting across its layers (about 11 MPa) | **Fixed M6 × 100 bolt**. The gear cluster and handle spin on its smooth shank |
| Torque path | Printed hex shaft | Handle sleeve (Ø11.6 journal in the +x wall) ending in a **9.8 mm hex** that fits an 8 mm-deep socket in the cluster |
| Depth stop | Ring on the shaft | **Split collar on the left rod** + 0–40 mm scale on the column + pointer fin on the head |
| Printed parts | 9 | **11** (+ test coupon) |
| Screws | 9 | **15** (all M3–M6 from your stock) |

Size: 140 × 188 mm base, **248 mm tall**. Clearance under the tool is 40 mm, and plunge travel is 40 mm.

## How the slide works (unchanged from v3)

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
| **Your screws** | see Hardware | M5 × 16 (6), M5 × 25, M5 × 20, M6 × 100 part-threaded |

**About the iron's hot zone.** The design fits a 60 mm hot zone with 3 mm to spare. If your iron's hot section is longer, `check.sh` fails, and the fix is a trade-off: less clearance under the iron or a smaller air gap.

**Print `stl/Preload_coupon.stl` first.** It has three test cells, marked by 1, 2 or 3 notches, each with the head's V seat and gib at a preload gap of −0.2, 0 or +0.2 mm. Slide each onto a rod **before cutting it**. Keep the cell with no play that still slides by hand, then adjust `gib_preload` until `gib_gap` matches that cell.

## Print list (PLA, Kobra 2 Neo, no supports)

Orientations are already applied in the STLs in `stl/`.

| Part | Orientation | Tall | Why this orientation | Settings |
|---|---|---|---|---|
| Base | Flat, as used | 35 | Plate bending lies along the layers | 4 walls, 25 % |
| Column (U-channel) | **Front face down** | 31 | The drilling reaction bends it along its 219 mm length, which now runs along the layers. The side walls print vertical, so the axle bosses are solid walls and the bores are true circles. **219 mm long on a 220 mm bed: place it diagonally, no brim** | 4 walls, 30 % |
| Rear cover | Flat, inner face up | 12 | Thin plate; the slider-guide ribs (both sides of the slider, and one right behind it at the mesh) grow straight up | 3 walls, 20 % |
| Top arm | Upside down (top face on the bed) | 35 | Plate; the skirt grows up from it, no 45° undersides | 4 walls, 30 % |
| Head | Upright | 70 | Unchanged from v3; the rack teeth print like a thread. The pointer fin has a 45° underside | 5 walls, 40 % |
| Gear cluster | Main pinion face down | 23 | Gears print flat: tooth bending lies along the layers | 100 % |
| Spring slider | On its side | 13 | Rack teeth along the layers | 100 % |
| Handle (3 spokes) | Spokes flat, sleeve up (y90) | 65 | Spoke bending lies along the layers. Twist does shear the layer bonds: 6.4 MPa in the round sleeve and **9.7 MPa in the hex end** at 30 N on a spoke (about 2× margin [Likely]). The hex flats carry the torque in bearing (5.4 MPa), along the layers | 4 walls, 40 %; 100 % for the sleeve if your slicer allows modifiers |
| Depth-stop collar | Flat, as used | 16 | Clamp ring bends in its own plane, along the layers. The M5 hole is a teardrop | 100 % |
| 555 sleeve / iron sleeve | Upside down (tabs on the bed) | 32 | As v3. The iron sleeve is PLA: treat it as replaceable | 4 walls, 40 % |

## Hardware

Owner-approved: M3–M6 screws and nuts from stock (2026-11-15), M6 ≥ 100 part-threaded. This list is `hw_bom` in `params.scad`; `check.sh` fails if the screw count changes without this table.

| Item | Qty | Use, and the side the driver comes from |
|---|---|---|
| Ø8 × 500 mm chrome rod (Robu), **cut to 2 × 245 mm**. Chamfer the cut ends | 1 | Guide rods |
| Bike kickstand spring | 1 | Head return: about 32 N at the top, 78 N at full plunge (modelled values) |
| **M5 × 16 socket + M5 nut** | 6 | Frame joints. Base: 2 per side, heads outside, nuts held inside. Arm: 1 per side, into **captive nut pockets** |
| **M5 × 25 socket + M5 nut** | 1 | Depth collar clamp (head on the +x side) |
| M5 × 20 socket + M5 heat-set insert | 1 | 43 mm ring clamp |
| M3 × 6 grub + M3 heat-set insert | 2 | Rod retention in the top arm |
| M3 × 16 thread-forming, Ø2.6 pilot | 2 | Bottom gib adjusters, driven from the head's front face |
| M3 × 10 thread-forming, Ø2.6 pilot | 2 | Top gib adjusters, driven from behind the head, beside the column |
| **M6 × 100 part-threaded bolt + 2 M6 nuts** | 1 | Fixed axle. Head at +x on the handle; nut + jam nut outside the −x wall. Threads only at the −x end |

Totals: **15 screws, 9 nuts, 3 heat-set inserts.** The bolt lengths come from `hardware.py pick` (2 threads past the nut).

**Recommended, not modelled:** a heat-proof work pad (thin aluminium or hardboard, 40 × 40 × 3 mm) in the base pocket for insert work. The iron tip reaches 1.5 mm into that pocket.

## Assembly order

Checked against the model: every nut is reachable when it's fitted, and no part has to pass through another to get in.

1. **Inserts.** Fit the M5 insert in the ring ear and the two M3 inserts in the arm's grub holes. Run the gib adjusters in until they just touch the blades.
2. **Base + column.** Set the column foot into the base pocket. Push 4 × M5 × 16 in from outside through the base collar and column walls, and hold the nuts inside through the open back. The rear −x nut sits next to the spring post, so use pliers.
3. **Top nuts.** Press 2 M5 nuts into the hex pockets inside the column top, one per side wall, flats facing front and back. A dab of glue or tape keeps them from falling out.
4. **Rods, collar, head.**
   - Put the rods in the base sockets.
   - Clamp the **depth collar** on the left rod with its top **118 mm above the base top**. That is depth 0, the head's top position.
   - Slide the **head** down the rods (the gib bumps have lead-ins) until it sits on the collar. Its rack is now beside the pinion window.
5. **Gear cluster, in from the open back.**
   - Move it forward until the main pinion meshes the head's rack, and line its bore up with the bosses.
   - Do this **before** the slider: the slider sits behind the spring pinion and would block the way.
6. **Handle + axle.**
   - Push the handle's sleeve through the +x bore; turn it until its hex end slides into the cluster's hex socket.
   - Push the M6 × 100 in from +x through the handle, cluster and −x boss.
   - At −x, run the nut on finger-tight, then lock the jam nut against it. Nothing that turns should be clamped.
7. **Slider + spring.**
   - Hook the spring's lower hook through the post's hole.
   - Push the **spring slider** forward onto the spring pinion with its tab resting on the ledge (the top stop).
   - Hook the spring's upper hook into the slider's cross-hole. That takes about 11 mm of stretch, roughly 32 N, so use long-nose pliers or a wire loop.
8. **Rear cover.** Drop it in from above, down the column's back and into the base pocket. Its side ribs pass either side of the slider (about 0.6 mm from the spring), and the back rib slides down 0.3 mm behind the slider. That back rib keeps the gear teeth from pushing the slider out of mesh.
9. **Top arm.**
   - Lower it over the column top, cover and rod tops.
   - Fit 2 × M5 × 16 from outside into the captive nuts.
   - Lock the rods with the 2 grubs.
10. **Depth.** Loosen the collar and drop it. Press the head down until the pointer's top edge reads the depth you want, then slide the collar up against the head and tighten the M5 firmly.
11. **Tools.** The 775 goes straight into the ring. The 555 and the iron go in their sleeves, with the sleeve's split lined up with the ring's. Set the height, then clamp the M5.

## Depth stop: what holds it

- The collar is a C-ring with a thin back that acts as a hinge, so the M5 squeezes the rod through a lever (24 / 9 = 2.7×).
- Sustained M5 preload is limited by PLA creep under the screw head: about 400 N at 12 MPa.
- That gives about **630 N of friction hold, against 171 N of rack force** at 30 N on the 60 mm spoke, so 3.7× (asserted ≥ 3×). [Likely: the hinge factor assumes the back flexes. The 16 mm height keeps the hinge ligament at 8.5 MPa, under the creep limit.]
- With no hinge action, the hold falls to about 240 N, still 1.4× a hard 30 N shove. **Test it before you trust it:** clamp the printed collar on a spare rod offcut, hang 20 kg (about 200 N) from it, and see that it doesn't slip. **Re-tighten the collar after the first day**: PLA relaxes.

## Tuning

- **Slide play:** turn the gib adjusters in a little. **Stiff slide:** back them off.
- **Head doesn't return fully:** the spring is weaker than modelled. Measure `ks_k` and `ks_T0`, update them, and `check.sh` will move the anchor post. Reprint the base only if the post moves.
- **Bits snapping:** check for play first, then feed more slowly. At 5.7 : 1 the handle is sensitive.
- **Collar slips:** tighten it again (creep). If it keeps slipping, the next step is a wider M5 bearing face (a washer). That is extra hardware, so it's not in this build.

## Numbers the model checks (`check.sh`, all 7 poses × tools)

- Joint keys seated: column~base, arm~column, cover~column all touch. Bolt heads seat on the collar and skirt; the arm nuts sit in their pockets (≤ 0.2 mm).
- The handle passes the +x bore on the way in: its hex corners are at r 5.66 and the bore is r 5.84 (asserted, as clash checks only test the final pose).
- No bolt passes through a part. Modelling the bolts caught the base's rear bolt running through the spring post, so it moved to y 94.5.
- The cover's insertion path misses the arm nut pockets (asserted in plan view).
- Bearing pressure on the M6 ≤ 5 MPa. Handle sleeve shear ≤ 8 MPa. Cluster core shear ≤ 8 MPa.
- Column bending at 50 N drilling force: **2.8 MPa**, open U only, cover ignored.
- Depth collar: touches the head at full plunge and is ≥ 1 mm clear in every other pose. Its jaw pressure on the rod is 8.2 MPa (≤ 12), and its hinge ligament carries 8.5 MPa (≤ 10).
- 11 printed parts, 15 screws.

## Print-rule audit (2026-11-15, v3.1)

Checked against the vendored skills (`common/skills/3d-print-designer`, `common/skills/openscad`) with `asm.py --print --walls 1.2` and `validate_stl.py`:
- **No supports.**
  - The column's nut-pocket roofs are 2.2 mm bridges, flats-up hexes, so there are no 60° roofs.
  - The head's slot ceilings are 12 mm bridges, and its only steep faces are the rack flanks (thread-like).
  - The pointer fin has a 45° underside.
  - The only "overhangs" on the base and arm are the elephant-foot chamfers at bed level.
- **No print over 120 mm tall.** The tallest is the head at 70 mm. Every part fits 220 × 220; the column fits only just, so place it diagonally.
- **Load along the layers.**
  - Column bending runs along its length.
  - Gear teeth, the handle spokes and the collar ring all print flat.
  - The axle is steel now. The one printed part loaded in twist is the handle sleeve: 6.4–9.7 MPa of interlayer shear, see the print list.
- **Fillets:** as v3. They are at the gib blade roots, the ring neck, the clamp-ear gussets, the slider tab and the handle spokes.
- **0.4 mm elephant-foot chamfers:** as v3, plus the collar bore.
- **Holes:** modelled at exact ISO fits (OpenSCAD skill rule). Horizontal holes are teardrops pointing up in each part's print orientation. Turn on hole/XY compensation in your slicer.

Known validator flags, all reviewed and accepted:
- **Column:** 0.4 mm ridges between the 1 mm-pitch scale grooves (cosmetic).
- **Gear cluster:** module-1 tooth tips.
- **Sleeves:** split corners where they leave a curved surface.
- **Top arm:** knife edges where the rod holes exit.
- **Base and arm:** elephant-foot chamfers on the bed.

## Check / regenerate

```
bash check.sh                                                       # 7 poses × tools: clash/fit checks + all asserts
python3 ../../../common/skills/openscad/scripts/asm.py drill_press_v3.scad --print --walls 1.2
python3 ../../../common/tools/validate_stl.py stl/*.stl
```
