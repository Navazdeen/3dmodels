# Bench Drill Press Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Parametric OpenSCAD model of a compact, PLA-printed bench drill press with swappable 555 / 775 / pen-iron heads, exported as validated, print-oriented STLs.

**Architecture:** One assembly file declares the `parts`/`checks`/`travel`/`report` tables that the vendored `openscad` skill's `asm.py` reads. Geometry lives in small module files grouped by sub-assembly, and every one of them includes a single `params.scad`. "Tests" are `checks` rows plus `asm.py --check --clash`, run in three plunge poses (variants), and `validate_stl.py` on each printed part.

**Tech Stack:** OpenSCAD 2025 (Manifold, WASM build installed by `common/skills/openscad/scripts/setup.sh`), `common/skills/openscad/scripts/{asm.py,render.sh,hardware.py}`, `common/tools/validate_stl.py`, `common/skills/3d-print-designer/` (PLA rules, design review).

**Spec:** `projects/bench_drill_press/design.md`

## Global Constraints

- Material PLA, all printed parts. No PLA within the iron's hot zone (`iron_hot_len`); at least `iron_air_gap` = 10 mm of air between any part and the hot barrel.
- Printer Kobra 2 Neo: every printed part, in its `print=` orientation, fits 220 × 220 × 250 mm.
- Compact envelope: base ≤ 140 × 160 mm (tolerance 5 mm), overall height ≤ 280 mm.
- Rods: 2 × Ø8 × 250 mm (`hw_rod`). Sleeves: OD 15 × 24 mm (LM8UU envelope), 4 per carriage.
- Plunge travel 40 mm. Clearance (base top to tool tip, head up, holder at its highest) ≥ 40 mm. Lowest holder + full plunge: tip reaches the base work pad (z ≤ 0).
- Reach: spindle axis 50 mm in front of the rod plane, centred between the rods.
- Hardware only from design §6: M8 pivot bolt + nyloc, M5 ×3 (thumb screw, link pin, depth stop), M3 ×~12 + heat-set inserts, motor face screws, kit extension spring 7.14 × 50.8 or 7.93 × 44.4. Anything else requires asking the owner first (AskUserQuestion).
- Printability: `validate_stl.py` clean (walls ≥ 1.2 mm, overhang ≤ 45°, bridges < 20 mm, flat on bed) or each exception justified in a comment.
- Motor and iron sizes are UNVERIFIED defaults until the owner measures them (design §8). Each lives in one `params.scad` line marked `// UNVERIFIED`.
- Units mm. Origin: spindle axis at x = y = 0, base top surface at z = 0, rods at +y (behind the tool).

## Review Focus

1. **Motor or iron not matching the typical sizes:** changing one `params.scad` value must re-fit the holder without other edits. Task 5 runs a check sweep at ±1 mm body diameter.
2. **Heat creeping into PLA from the iron:** the iron holder must never come closer than 10 mm to the hot zone, at any holder height. Task 5 has a check row against `hw_iron_hot`.
3. **Rods slipping or the top twisting under insert-pressing force (about 50 N at the tip, about 200 N at the pivot with 4:1):** rod clamps must squeeze with a split and screw, not rely on a press fit alone. Task 2 has a check that the clamp slot exists (gap ≥ 1 mm before tightening).
4. **Printed sleeve bore wrong for this printer:** the bore test set must span undersize to oversize so one of them fits. Task 3 has a check that the test set covers 7.9–8.4 mm.
5. **775 vibration loosening the dovetail:** the dovetail must lock with a screw pressing on a flat, not on an angled face. Task 5 has a check row showing the screw tip touches the flat.

---

## File Structure (all under `projects/bench_drill_press/`)

| File | Responsibility |
|---|---|
| `params.scad` | Every dimension and derived value. No geometry. |
| `frame.scad` | `base()`, `top_bridge()`, `spine_lower()`, `spine_upper()`, `rod_clamp_cut()` |
| `carriage.scad` | `carriage()`, `sleeve(bore)`, `dovetail_socket()` |
| `lever.scad` | `lever()`, `thumbwheel()` |
| `holders.scad` | `dovetail_key()`, `holder_555()`, `holder_775()`, `holder_iron()`, `lock_knob()` |
| `hardware.scad` | Reference solids for `hw_` parts: rods, motors, iron (hot zone as its own solid), screws, spring |
| `bench_drill_press.scad` | The assembly: include params, use the module files, the `parts/checks/travel/report/variants` tables, and the `pick()` lines |
| `sleeve_test.scad` | Separate small print: 6 sleeves, bores 7.9 / 8.0 / 8.1 / 8.2 / 8.3 / 8.4, each labelled |
| `bench_drill_press_log.md` | Design log (`asm.py --log`) |

Poses: `variants = ["up","mid","down"]`, and `plunge = variant=="up"?0 : variant=="mid"?20 : 40;` in `params.scad`. Carriage z and lever angle are both derived from `plunge`, so every `--check --clash` run covers all three poses. Holder height is the parameter `holder_z` (0 = lowest), and its range is checked in Task 5.

Common commands (from `projects/bench_drill_press/`, with `S=../../common/skills/openscad/scripts`):
- `python3 $S/asm.py bench_drill_press.scad --check --clash --brief`: expected output contains no `FAIL`, `ERROR`, `NOT WATERTIGHT` or clash lines except contacts listed in `flex=`.
- `python3 $S/asm.py bench_drill_press.scad --print` then `python3 ../../common/tools/validate_stl.py bench_drill_press_print/*.stl`: expected, no part reports a failed check.

---

### Task 1: Params, hardware references, base

**Files:**
- Create: `params.scad`, `hardware.scad`, `frame.scad` (only `base()` here), `bench_drill_press.scad`

**Interfaces:**
- Produces in `params.scad`: `rod_d=8`, `rod_len=250`, `rod_pitch` (x distance between rods, Claude's call, 70), `rod_y=50`, `base_w=140`, `base_d=160`, `base_t=20`, `rod_socket_depth=18`, `plunge`, `travel_len=40`, `clear_min=40`, `bed=[220,220,250]`, `m3_insert=[4.0,5.0]` (hole Ø, depth; UNVERIFIED until owner's insert size known), `m5_insert=[6.4,8.0]`, `$fn` rule (64 iterate, 128 final).
- Produces in `hardware.scad`: `hw_rod()`. Rods are at x = ±rod_pitch/2, y = rod_y, from z = −rod_socket_depth to `rod_top_z = rod_len − rod_socket_depth`.
- `parts` rows: `["base","Base","PLA",[0,0,-30],"print=auto"]`, `["hw_rod","Rod Ø8×250","",[0,0,0],"pieces=2"]`.

- [ ] **Step 1: Write the failing checks.** Add to `checks`: `["hw_rod","base","overlap"]` (the rod sits in its socket), and `report` rows `["base w", base_w]`, `["base d", base_d]`, `["rod top", rod_top_z]`.
- [ ] **Step 2: Run** `asm.py --check`. Expected: an error or FAIL, because `base` isn't defined yet.
- [ ] **Step 3: Implement `base()`.** Plate `base_w × base_d × base_t`, top at z = 0. Rod sockets Ø`rod_d` H7 (use `fit_mid("H7",8)` from `../../common/skills/openscad/lib/fits.scad`), depth 18, each with a split clamp: a 1.2 mm slot and an M3 cross screw into an insert. A replaceable work pad pocket (40 × 40 × 3 mm) centred on the spindle. Spine mount boss at the back with 2 M3 inserts. 4 × Ø4.5 bench screw holes. Fillets and chamfers as in the existing kobra project's style.
- [ ] **Step 4: Run** `asm.py --check --clash --brief`. Expected: no FAIL. `hw_rod`/`base` overlap is reported as contact inside the socket only, so tag the rods `flex=base` if needed. Report: base w 140, base d 160.
- [ ] **Step 5: Commit** `git add projects/bench_drill_press && git commit -m "Drill press: params, rods, base"`

### Task 2: Top bridge and back spine

**Files:** Modify `frame.scad`, `bench_drill_press.scad`, `params.scad`

**Interfaces:**
- Consumes `rod_pitch`, `rod_y`, `rod_top_z`, `rod_clamp_cut()`.
- Produces `bridge_z0` (underside of the top bridge), `pivot_pos=[x,y,z]` (lever pivot axis point; the axis runs along x), `spring_anchor_bridge=[...]` (a list of 4 anchor hole points on the bridge), and the modules `top_bridge()`, `spine_lower()`, `spine_upper()`.

- [ ] **Step 1: Write the failing checks.** `["top_bridge","hw_rod","overlap"]`, `["spine_lower","base","touch"]`, `["spine_upper","top_bridge","touch"]`, `["spine_lower","spine_upper","touch"]`. In `report`: `["overall h", <top of bridge z> + base_t]` with `checks` row `["overall h",...]` (add as a report and also an `assert(top_z + base_t <= 280)` in `params.scad`). Clamp slot gap: `assert(clamp_slot >= 1)`.
- [ ] **Step 2: Run** `asm.py --check`. Expected: FAIL / undefined parts.
- [ ] **Step 3: Implement.** The bridge clamps both rod tops (same split clamp as the base). The pivot boss is Ø8 H9 for the M8 bolt, with its width along x ≥ 24 mm for bearing length. The spring anchor row has 4 holes, 6 mm apart. The spine is 2 parts with a 20 mm lap joint and 2 × M3, mounted to the base and bridge with 2 × M3 each. The spine section is at least a 30 × 8 mm rib behind the rods, so it can't clash with the carriage.
- [ ] **Step 4: Run** `asm.py --check --clash --brief`. Expected: no FAIL; overall h ≤ 280.
- [ ] **Step 5: Run** `asm.py --print`, then check that every printed part's height and footprint fit `bed`. Expected: the `--print` report shows no part over 220 × 220 × 250.
- [ ] **Step 6: Commit** `"Drill press: top bridge and 2-part spine"`

### Task 3: Sleeves, carriage, sleeve test set

**Files:** Create `carriage.scad`, `sleeve_test.scad`. Modify `params.scad`, `bench_drill_press.scad`.

**Interfaces:**
- Consumes `rod_pitch`, `rod_y`, `plunge`, `bridge_z0`.
- Produces `sleeve_od=15`, `sleeve_len=24`, `sleeve_bore=8.1` (default until the owner's test print picks one), `carriage_h`, `carriage_z0_up` (carriage bottom at plunge 0), `carriage_z0 = carriage_z0_up - plunge`, `link_pin_pos` (M5 pin point on the carriage, which moves with it), `dovetail_origin` (bottom-centre of the socket on the carriage front face), `stop_screw_pos`, and the modules `carriage()`, `sleeve(bore)`, `dovetail_socket()`.
- `parts`: `["carriage",...,"print=auto"]`, `["sleeve","Sleeve","PLA",[0,0,0],"qty=4","flex=carriage"]`.

- [ ] **Step 1: Write the failing checks.** Add these rows:
  - `["carriage","hw_rod",">=",0.3,"travel"]`: the carriage body never rubs the rods, only the sleeves do.
  - `["carriage","base",">=",3]`: holds in all variants, so the carriage clears the base at `down`.
  - `["carriage","top_bridge",">=",3]`: holds at `up`.
  - `["carriage","spine_lower",">=",2]` and `["carriage","spine_upper",">=",2]`.

  Add `assert(sleeve_pitch >= 46)` (the gap between sleeve centres on one rod). In `sleeve_test.scad`: `assert(min(bores)<=7.9 && max(bores)>=8.4)`.
- [ ] **Step 2: Run** `asm.py --check` for all variants. Expected: FAIL / undefined.
- [ ] **Step 3: Implement.** Each sleeve pocket is Ø15 H7 × 24 with a 1 mm slit and an M3 squeeze screw. Sleeves are spaced as far apart as `carriage_h` allows (Claude's call: `carriage_h` = 72 gives a 48 mm pitch). The sleeve has a 0.5 mm × 45° lead-in chamfer and 3 shallow grease grooves. The dovetail socket is vertical, 60° (Claude's call), 30 mm wide, as tall as `carriage_h`, with an M5 insert through to a flat lock face. Also the link pin boss (M5) and the stop screw boss (M5 insert, vertical, pointing down at the base stop pad). `sleeve_test.scad` has 6 sleeves with the bore value embossed 0.6 mm deep on the end face.
- [ ] **Step 4: Run** `asm.py --check --clash --brief` (all 3 variants), then `render.sh sleeve_test.scad --no-png`. Expected: no FAIL, sleeve_test watertight.
- [ ] **Step 5: Commit** `"Drill press: carriage, LM8UU-envelope sleeves, bore test set"`

### Task 4: Lever, link, spring anchors, counterweight, depth stop

**Files:** Create `lever.scad`. Modify `params.scad`, `hardware.scad`, `bench_drill_press.scad`.

**Interfaces:**
- Consumes `pivot_pos`, `link_pin_pos`, `spring_anchor_bridge`, `stop_screw_pos`, `plunge`.
- Produces `lever_ratio` (handle length / pin radius, ≈ 4), `lever_angle(plunge)` (a function returning the angle in degrees, solved from `pivot_pos`, `link_pin_pos` and the slot), `spring_anchor_lever` (3 holes near the pivot), `spring_stretch` (a report value), and the modules `lever()` and `thumbwheel()`. In `hardware.scad`: `hw_pivot` (M8 bolt), `hw_link_pin`, `hw_stop_screw`, `hw_spring` (7.14 × 50.8, `flex=lever,top_bridge`).

- [ ] **Step 1: Write the failing checks.**
  - `["lever","top_bridge",">=",1]`, `["lever","spine_upper",">=",1]` and `["lever","hw_rod",">=",1]`, holding in all variants.
  - `["hw_stop_screw","base","touch"]`, holding at `down` only (use the variant suffix in the row as `asm.py` allows, or an `assert` on `stop_screw_tip_z` in params).

  Add these asserts, plus `report` rows for `spring_stretch` and the lever angle at each variant:
  - `assert(spring_stretch(40) <= 15)` (keeps the kit spring well inside its range)
  - `assert(abs(lever_ratio-4) <= 0.5)`
  - `assert(lever_angle(40) - lever_angle(0) <= 75)`
- [ ] **Step 2: Run** `asm.py --check`. Expected: FAIL / undefined.
- [ ] **Step 3: Implement.** The lever pivots on the M8 bolt through the bridge boss. A slot in the lever engages the carriage pin. Its length must cover the pin's arc across 0–40 mm of plunge (compute it in `params.scad`, don't hard-code it). The handle sits on the right side and is ≥ 150 mm from the pivot, unless that overshoots the compact envelope; then shorten it and accept a lower `lever_ratio` down to 3.5, recording the decision in the log. There are 3 spring holes 8–20 mm from the pivot. A counterweight pocket at the tail is 20 × 15 × 30 mm with a printed lid that snaps on. The thumbwheel is Ø25 mm, knurled, and fits a captured M5 nut, so turning the wheel turns the stop screw.
- [ ] **Step 4: Run** `asm.py --check --clash --brief`. Expected: no FAIL. Spring contact is allowed only at its seats.
- [ ] **Step 5: Commit** `"Drill press: lever, link, spring anchors, counterweight, depth stop"`

### Task 5: Dovetail key, tool holders, lock knob

**Files:** Create `holders.scad`. Modify `params.scad`, `hardware.scad`, `bench_drill_press.scad`.

**Interfaces:**
- Consumes `dovetail_origin`, the dovetail profile params from Task 3, `carriage_z0`, and `holder_z`.
- Produces the modules `dovetail_key(h)`, `holder_555()`, `holder_775()`, `holder_iron()` and `lock_knob()`.
- Produces these UNVERIFIED params:
  - 555: `m555_d=35.8`, `m555_len=57`, `m555_screw=["M3",25]`
  - 775: `m775_d=42`, `m775_len=67`, `m775_screw=["M4",29]`
  - chuck and bit: `chuck_len=40`, `bit_stickout=20`
  - pen iron: `iron_grip_d=[18,26]` (clamp range), `iron_grip_len=40`, `iron_hot_len=60` (hot zone measured from the tip), `iron_air_gap=10`
- Produces `tool` (the variant-independent selector `"775"|"555"|"iron"`), and `tip_z(holder_z,plunge)`.
- In `hardware.scad`: `hw_motor`, `hw_chuck_bit`, `hw_iron_handle`, `hw_iron_hot`.
- Note: 555 M3 face screws are fine. **775 face screws are M4, which isn't in the approved list** (the design says "usually supplied with the motor"). If the motor didn't come with them, ask the owner before modeling around any other size.

- [ ] **Step 1: Write the failing checks.**
  - `["holder_iron","hw_iron_hot",">=",iron_air_gap]`
  - `["holder_775","carriage","touch"]`
  - `["lock_knob","holder_775","touch"]` (the screw lands on the flat)
  - `["hw_chuck_bit","base",">=",0]` at `up`

  Add these asserts:
  - `assert(tip_z(holder_z_max,0) >= clear_min)`
  - `assert(tip_z(0,travel_len) <= 0)`
  - `assert(holder_z_max >= 45)`

  Add a sweep: `render.sh chk.scad --sweep m775_d=41,42,43`, where every case renders and the holder bore follows.
- [ ] **Step 2: Run** `asm.py --check` with `tool=775`, then `555`, then `iron` (`--define`, or one variant set per tool). Expected: FAIL / undefined.
- [ ] **Step 3: Implement.** All three holders share `dovetail_key(h)`, where h is the holder height and the key has a flat for the lock screw.
  - **555 and 775:** a cradle bore at `fit_mid("H9", d)` wraps 200° of the motor body. Face screws pass through a front plate with vent cut-outs, and the motor axis sits on the spindle axis.
  - **Iron:** a split clamp covering the `iron_grip_d` range, plus a pair of printed V-pads so different diameters centre. The clamp sits only on the handle, above `iron_hot_len + iron_air_gap`. Vent slots run between the clamp and the barrel.
  - **Lock knob:** printed, Ø20 mm, captures the M5 screw head.
- [ ] **Step 4: Run** `asm.py --check --clash --brief` for each tool. Expected: no FAIL; all asserts hold.
- [ ] **Step 5: Commit** `"Drill press: dovetail key, 555/775/iron holders, lock knob"`

### Task 6: Full verification, print files, viewer, docs

**Files:** Modify `bench_drill_press.scad` (`print=` tags, `plate=`), `README.md`. Create `bench_drill_press_log.md` (via `--log`).

- [ ] **Step 1: Run** `asm.py bench_drill_press.scad --check --clash --walls 1.2 --print --bom`, for every variant and every tool. Expected: no FAIL, no `even wall` regions below 1.2, and every part fits the bed.
- [ ] **Step 2: Run** `python3 ../../common/tools/validate_stl.py bench_drill_press_print/*.stl --json validation_report.json`. Expected: every check passes, or each exception is explained in the scad comment next to the feature.
- [ ] **Step 3: Design review.** Go through `../../common/skills/3d-print-designer/design-review.md` against the model. Fix findings or log them.
- [ ] **Step 4: Run** `asm.py bench_drill_press.scad --html --title "Bench Drill Press"`, then `--log "v1: first complete model"`. Expected: `bench_drill_press.html` and `bench_drill_press_log.md` exist.
- [ ] **Step 5: Update** `README.md` with:
  - the print list (part, qty, orientation, infill suggestion: 4 walls, 30–40 % for the frame, 100 % for the sleeves)
  - the BOM from `bench_drill_press_bom.csv`
  - assembly order (which side each screw is driven from, and at which step)
  - the sleeve test procedure: print `sleeve_test`, keep the bore that slides without play, set `sleeve_bore`
  - the list of UNVERIFIED dimensions the owner must measure
- [ ] **Step 6: Commit and push** `"Drill press: verified v1, print files, viewer, BOM"` to `ccr-678cddca-ns2zel`.
