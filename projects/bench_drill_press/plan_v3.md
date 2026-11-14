# Bench Drill Press v3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Model v3 of the bench drill press: preloaded V-slide on two Ø8 rods, centre rack-and-pinion feed, one-piece C-frame, 43 mm collar with tool sleeves, in about 10 printed parts.

**Architecture:** Same toolchain as v2. One assembly file declares the `parts`/`checks`/`report`/`variants` tables for `common/skills/openscad/scripts/asm.py`. Geometry lives in small module files that all include `params.scad`. Tests are asserts in `params.scad` plus asm `checks` rows, run by `v3/check.sh` over pose × tool variants.

**Tech Stack:** OpenSCAD 2025 (WASM, installed), `asm.py`, `render.sh`, `hardware.py`. Gears use BOSL2 (`gears.scad`), fetched once by the skill's `get_bosl2.sh` into the skill cache: a library, not a skill. `common/tools/validate_stl.py` checks printability.

**Spec:** `projects/bench_drill_press/design_v3.md`

## Global Constraints

- Material: PLA for all parts. Iron sleeve keeps **≥ 15 mm** of air to the hot zone.
- Printer: Kobra 2 Neo. Every part, in its `print=` orientation, fits 220 × 220 × 250 mm, with no supports.
- Rods: 2 × Ø8 cut from one 500 mm rod. Each rod ≤ 250 mm.
- Slide: 90° V on the left rod, flat pad on the right rod. **Rigid seats sit on the side the feed tips into: top seats in front of the rods (−y), bottom seats behind (+y).** Flexure gibs sit opposite, preload ≈ 3 N each, one M3 re-tightens each one.
- Feed: rack and pinion, module 1.5, 14 teeth (pitch radius 10.5), handle spokes ≈ 60 mm, travel 40 mm.
- Return: kickstand spring on a printed slider rack, driven by a small pinion on the same shaft. Torque ≥ 1.25 × (head weight + slide friction) × 10.5 at the top. Kickstand values UNVERIFIED: L0 75, k 2.0 N/mm, T0 10 N, max extension 0.5 × L0.
- Depth stop: ring clamped (1 M3) on a **round** shaft section, with an mm scale, against a lug on the column.
- Tool mount: 43 mm split ring on the head, 1 M5. Sleeves: 775 shim, 555 sleeve, iron sleeve. Tool height is set by sliding the tool in the ring.
- Origin as in v2: spindle axis at x = y = 0, base top at z = 0, rods at x = ±35, y = 50.
- Clearance ≥ 40 mm (tip above base, head up, tool highest). At full plunge with the tool lowest, the tip reaches the work-pad pocket (−3 ≤ z ≤ 0).
- Counts: printed parts ≤ 10, screws ≤ 8 (excluding motor face screws). Hardware only from design §6. Anything new needs the owner's OK (AskUserQuestion).
- Motor, iron, spring and head-weight values are marked `// UNVERIFIED`, one line each in `params.scad`.

## Review Focus

1. **Spring direction:** the return spring must lift the head, not help it down. Task 3 adds an assert that the return torque is > 0 at both the top and the bottom.
2. **Rack disengaging at the ends of travel:** Task 3 checks that rack/pinion engagement covers travel + 2 mm at each end.
3. **Flexure gib over-stressed at its preload deflection:** PLA creeps above about 15 MPa. Task 2 asserts the gib bending stress is ≤ 15 MPa.
4. **Tool slipping in the 43 mm ring under thrust:** Task 4 asserts that clamp friction ≥ 3 × 50 N.
5. **Iron sleeve heat at any slide position in the ring:** Task 4 checks a ≥ 15 mm gap at the sleeve's lowest and highest positions.

---

## File Structure (all under `projects/bench_drill_press/v3/`)

| File | Responsibility |
|---|---|
| `params.scad` | Every dimension, derived value, the variant → pose/tool parse, and all asserts |
| `frame.scad` | `c_frame()`: base, hollow column, top arm, rod sockets, pinion bores, spring channel, stop lug |
| `head.scad` | `head()`: body around the rods, V and pad seats, `gib()` flexures, rack, 43 mm split ring |
| `drive.scad` | `pinion_shaft()`, `spring_slider()`, `handle_hub()`, `stop_ring()` |
| `sleeves.scad` | `shim_775()`, `sleeve_555()`, `sleeve_iron()` |
| `coupon.scad` | `preload_coupon()`: a short V + pad + gib block, printed first to tune the gib gap |
| `hardware.scad` | `hw_` reference solids: rods, kickstand spring, screws, motors, chuck + bit, iron and its hot zone |
| `drill_press_v3.scad` | Assembly tables and `pick()` lines |
| `check.sh` | The v2 runner, with the common path set to `../../../common` |

Variants: `up`, `mid`, `down` (775), `up_555`, `down_555`, `up_iron`, `down_iron`. `plunge` is 0, 20 or 40; tool height in the ring is highest at `up` and lowest at `down`.

Run from `v3/`, with `S=../../../common/skills/openscad/scripts`: `bash check.sh`. Expected: it ends with `check.sh: PASS`.

---

### Task 1: Params, rods, C-frame

**Files:** Create `v3/params.scad`, `v3/hardware.scad`, `v3/frame.scad`, `v3/drill_press_v3.scad`, `v3/check.sh`.

**Interfaces:**
- Produces (`params.scad`):
  - Rods: `rod_x=[-35,35]`, `rod_y=50`, `rod_d=8`
  - Base: `base_t=15`
  - Column: `col=[x0,x1,y0,y1]` (hollow box behind the rods, clear of rods by ≥ 3)
  - Top arm: `arm_z0` (underside)
  - Rods: `rod_len`, sockets `fit_mid("H7",8)`
  - Pinion: `pinion_axis=[y,z]` (shaft along x)
  - Plunge: `plunge`, `travel=40`
  - Printer: `bed=[220,220,250]`
  - Function: `frame_h()`
- Produces (`frame.scad`): `c_frame()`, `hw_rods()`.

- [ ] **Step 1: Write failing checks.**
  - `checks`: `["hw_rod","c_frame","<=",0.05]` (rods seated).
  - Asserts: `frame_h() <= bed[2]`; `rod_len <= 250`; base footprint ≤ 150 × 190.
- [ ] **Step 2: Run** `bash check.sh`. Expected: FAIL (c_frame undefined).
- [ ] **Step 3: Implement `c_frame()`.**
  - Base plate with a 40 × 40 × 3 work-pad pocket at the origin.
  - Hollow column, 3 mm walls, with a front window where the pinion meets the rack.
  - Top arm on 45° gussets (no supports).
  - Through-holes in the top arm and blind sockets in the base for the rods, each with one horizontal M3 retaining hole (teardrop).
  - Pinion shaft bores at `pinion_axis`, H9 on the shaft diameter.
  - Spring channel inside the column, and the stop lug on the −x outside face.
  - Prints as modelled.
- [ ] **Step 4: Run** `bash check.sh` and `asm.py drill_press_v3.scad --variant up --print --brief`. Expected: PASS; the frame shows 0 overhang except bed-edge chamfers.
- [ ] **Step 5: Commit** `"v3: params, rods, one-piece C-frame"`.

### Task 2: Head with preloaded V-slide, rack and collar

**Files:** Create `v3/head.scad`. Modify `params.scad` and the assembly.

**Interfaces:**
- Consumes: rods, `pinion_axis`, `plunge`.
- Produces:
  - Head size: `head_h=70`, `seat_z=[z_lo,z_hi]` (spacing ≥ 56)
  - Rack: `rack_pitch_y = pinion_axis[0] - 10.5`, `rack_len`, `rack_offset_y` (rack pitch line to spindle axis)
  - Gib: `gib_preload=3`, `gib_k` (N/mm, from beam formula), `gib_gap` (deflection at assembly), `gib_stress()`
  - Collar: `ring_d=43`
  - Modules: `head()`, `gib()`
- `parts`: `head`, plus `hw_gib_screws` (`pieces=2`).

- [ ] **Step 1: Write failing checks.**
  - `["head","hw_rod","touch"]`: seats touch the rods in every pose.
  - `["head","c_frame",">=",1]` in every pose.
  - Asserts:
    - `gib_stress() <= 15` (MPa)
    - Rigid seats carry the feed moment: `50 * rack_offset_y / (seat_z[1]-seat_z[0])` > 0 and acts on seats on the `top front / bottom back` sides. Encode the seat sides as `seat_side=[-1,+1]` and assert `seat_side == [-1,+1]`.
    - Reverse moment from return + weight ≤ 2 × `gib_preload` × spacing.
    - `ring_d == 43`.
- [ ] **Step 2: Run.** Expected: FAIL (head undefined).
- [ ] **Step 3: Implement `head()`.**
  - Clearance holes Ø8 + 3 for the rods.
  - Left rod: a 90° V at `seat_z[1]` on −y and at `seat_z[0]` on +y. Right rod: flat pads on the same sides.
  - `gib()`: cantilever PLA flexures opposite each seat, pressing the rods at `gib_gap` interference. Model them at their rest position overlapping the rod by `gib_gap`, and tag the rods `flex=head`.
  - One M3 insert per gib pair to re-tighten.
  - Rack along z on the rear face, m1.5, length = travel + 2 × 2 + pinion engagement, made with BOSL2 `rack()`.
  - 43 mm split ring around the spindle axis at the head's front, with an M5 clamp screw in an insert across the split.
  - Prints upright, no supports. The V flanks are 45°.
- [ ] **Step 4: Run** `bash check.sh`. Expected: PASS in all 7 variants.
- [ ] **Step 5: Commit** `"v3: head with preloaded V-slide, rack, 43 mm collar"`.

### Task 3: Drive (pinion shaft, spring slider, handle, depth stop)

**Files:** Create `v3/drive.scad`. Modify `params.scad`, `hardware.scad` and the assembly.

**Interfaces:**
- Consumes: `pinion_axis`, `rack_pitch_y`, `rack_len`, `plunge`, `head_mass` (UNVERIFIED 0.55), the friction model `mu=0.3` × `gib_preload` × number of contacts.
- Produces:
  - Main pinion: `pin_m=1.5`, `pin_z=14`, `pin_r=10.5`
  - Spring pinion: `spr_m=1`, `spr_z`, `spr_r`
  - Spring: `ks_*` values (UNVERIFIED)
  - Functions: `ret_torque(p)`, `ks_ext(p)`
  - Modules: `pinion_shaft()` (hex ends + a round stop section), `spring_slider()`, `handle_hub()` (3 spokes, r = 60), `stop_ring()` (mm scale, M3 clamp)
- `parts`: `pinion_shaft`, `spring_slider`, `handle_hub`, `stop_ring`, `hw_spring` (`flex=spring_slider,c_frame`).

- [ ] **Step 1: Write failing checks.**
  - Asserts:
    - `ret_torque(0) >= 1.25*(head_mass*9.81 + friction)*pin_r`
    - `ret_torque(travel) > 0` and `ret_torque(0) > 0` (direction)
    - `ks_ext(travel) <= 0.5*ks_L0`
    - Rack engagement: `rack_len >= travel + 4 + 2*pin_r*0.5`
    - Stop range covers 0–40 mm
    - Printed part count (`len` of made parts) ≤ 10, screw count ≤ 8
  - `checks`:
    - `["pinion_shaft","head","<=",0.3]` (mesh)
    - `["pinion_shaft","c_frame","<=",0.3]` (bores)
    - `["spring_slider","c_frame","<=",0.3]`
    - `["handle_hub","hw_rod",">=",2]`
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement.**
  - Shaft printed upright: main pinion, spring pinion, a round section for the stop, hex ends.
  - The shaft goes in through one column bore with a split bushing cap (printed into the frame as a snap), or as a 2-piece shaft joined by a hex socket. Pick the simpler one and ledger the ruling.
  - Slider: a vertical rack in the column channel, with a hook for the spring's top end. The spring's bottom hooks a peg in the base inside the column.
  - The handle hub fits the +x hex end and has 3 spokes with ball ends.
  - The stop ring clamps on the round section with an engraved 0–40 mm scale (1 mm ticks, 5 mm numbers by notches, no font). It hits the lug.
- [ ] **Step 4: Run** `bash check.sh`. Expected: PASS. The report shows return torque vs need at up and down.
- [ ] **Step 5: Commit** `"v3: rack-and-pinion drive, spring slider, handle, depth stop"`.

### Task 4: Tool sleeves and tool hardware

**Files:** Create `v3/sleeves.scad`. Modify `params.scad`, `hardware.scad` and the assembly.

**Interfaces:**
- Consumes: `ring_d=43`, `head()` ring height and position, `plunge`.
- Produces:
  - `tool` from the variant
  - `tool_z` (slide position in the ring; highest at `up`, lowest at `down`)
  - `tip_z()`
  - Modules: `shim_775()` (43 → 42 UNVERIFIED), `sleeve_555()` (43 → 35.8), `sleeve_iron()` (43 → handle Ø22 UNVERIFIED, slotted air-gap section, ≥ 15 mm to the hot zone)
- Tool-conditional `parts`, as in v2.

- [ ] **Step 1: Write failing checks.**
  - Asserts:
    - `tip_z(top) >= 40`
    - `-3 <= tip_z(bottom) <= 0`
    - Clamp friction `0.3 * clamp_force >= 150` N, using `clamp_force` from M5 preload ≈ 1000 N × ring compliance factor 0.5
  - `checks`:
    - `["sleeve_iron","hw_iron_hot",">=",15]` at `up_iron` and `down_iron`
    - `[sleeve,"head","<=",0.3]`
    - `["hw_chuck_bit","c_frame",">=",0]`
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement the sleeves.**
  - Each sleeve is a split tube so the ring's clamp passes through to the tool, with a lip that sets a reference height.
  - The iron sleeve is longer, with 4 slots in the air-gap section.
  - All print upright.
- [ ] **Step 4: Run** `bash check.sh`. Expected: PASS for all 7 variants.
- [ ] **Step 5: Commit** `"v3: 43 mm collar sleeves for 775, 555, iron"`.

### Task 5: Preload coupon, full verification, deliverables

**Files:** Create `v3/coupon.scad` and `v3/README.md`. Update `projects/bench_drill_press/README.md` to point to v3.

- [ ] **Step 1: Coupon.** `preload_coupon()` is a 30 mm-tall block with the same V, pad and gib profile on 2 short rod stubs, plus 3 gib-gap variants (−0.2, 0, +0.2 mm) side by side. Assert the gaps span ±0.2. Run `render.sh coupon.scad --no-png`. Expected: watertight.
- [ ] **Step 2: Run** `asm.py drill_press_v3.scad --check --clash --walls 1.2 --print --bom --brief` and `validate_stl.py`. Expected: no FAIL. The only exception is the coupon's separate bodies, which are intended.
- [ ] **Step 3: Export.** Copy the STLs to `v3/stl/`, then run `--html` for the viewer and `--log "v3: first complete model"`.
- [ ] **Step 4: README.** Cover:
  - The print list
  - The BOM: printed and screw counts, against v2's
  - Assembly order: the head goes between the arms before the rods drop in; shaft, slider and spring; then handle and stop
  - Tuning: the gib gap from the coupon, the spring preload
  - The list of UNVERIFIED values
- [ ] **Step 5: Commit and push** `"v3: verified model, print files, viewer, README"`.
