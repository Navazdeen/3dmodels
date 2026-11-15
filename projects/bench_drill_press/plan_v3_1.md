# Bench Drill Press v3.1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the v3 C-frame into 4 parts printed in their load-best orientations, replace the printed shaft with a fixed M6 axle (hex-driven gear cluster), and move the depth stop to a rod collar with a scale.

**Architecture:** This edits the existing `projects/bench_drill_press/v3/` model in place: same params / tables / asm.py / check.sh workflow. `frame.scad`'s single `c_frame()` becomes `base()`, `column()`, `rear_cover()` and `top_arm()`. `drive.scad` loses `shaft()` and `stop_ring()` and gains `gear_cluster()`, a new `handle_hub()` and `depth_collar()`.

**Tech Stack:** OpenSCAD + BOSL2 gears, `asm.py`, `validate_stl.py` (all installed).

**Spec:** `projects/bench_drill_press/design_v3_1.md` (amends `design_v3.md`)

## Global Constraints

- Everything in `design_v3.md` still holds unless the amendment changes it. PLA.
- Frame: base, column (U-channel: front wall + 2 side walls), rear cover, top arm. Joints are keyed for position and clamped with M5 bolts + captured nuts. The rear cover uses M3 screws into heat-set inserts.
- Print orientations: base flat; **column lying on its front face**; cover flat; arm flat; gear cluster flat; handle flat.
- Every printed part ≤ 120 mm tall in its print orientation, and fits 220 × 220 mm on the bed.
- Axle: M6 bolt, partly threaded, ≥ 100 mm, **fixed** (doesn't rotate), nut + jam nut outside the −x wall. The cluster and handle spin on the smooth shank.
- Bearing pressure on the M6 ≤ 5 MPa. Hex sleeve shear ≤ 8 MPa at 30 N on a 60 mm spoke.
- Depth collar on the left rod, 1 × M5 clamp; clamp friction ≥ 3 × the rack force at 30 N on the handle.
- Budget: ≤ 11 printed parts; screws counted and asserted from the BOM.
- All v3 checks keep passing: the 7 variants, slide, gears, spring, heat gap, tip reach and clearance.

## Review Focus

1. **The column is longer than the bed when lying down.** The v3 column runs to about z 189 + arm. Task 1 asserts column length ≤ 215 (a thicker arm brings the joint down).
2. **The rods are no longer parallel** because of joint slop. The keys must locate the base and arm sockets. Task 1 checks that the keys touch and asserts key clearance ≤ 0.2.
3. **The handle's hex sleeve doesn't reach the cluster socket**, or rubs the +x boss. Task 2 checks sleeve ↔ cluster ≤ 0.3 and sleeve ↔ column bore ≤ 0.3, with no overlap.
4. **The depth collar collides with the head or slide at full plunge.** Task 3 makes the check pose-conditional: touch at `down`, ≥ 1 elsewhere.
5. **Assembly order is impossible.** For example, the cluster can't go in with the cover on, or the bolt can't pass. Task 4's README order is checked against the geometry: the cover is off, nothing threads through a nut.

---

### Task 1: Split the frame (base, column, rear cover, top arm)

**Files:** Modify `v3/params.scad`, `v3/frame.scad`, `v3/drill_press_v3.scad`.

**Interfaces:**
- Produces:
  - Params: `arm_t = 16` (top arm thickness; arm bottom at `arm_top - arm_t`), `col_top = arm_top - arm_t`, `key = [w, depth, clearance 0.2]`, `m5_nut = [8.1, 4.2]` (across flats, thickness), `joint_m5_n = 4 + 2`
  - Modules: `base()`, `column()`, `rear_cover()`, `top_arm()`
  - Part ids `base`, `column`, `rear_cover`, `top_arm`; the id `c_frame` is removed.
  - Every check that named `c_frame` names the right new part. Use a group `frame` (`group=frame` tag) where any frame part will do.
- The column keeps the bearing bosses (bore now for M6: `fit_mid("H9", 6)`, boss length ≥ 8 per wall), the slider guides, the ledge and the anchor bar.
- The rear access window is removed; the cover closes the back.
- The stop-pin arm is removed (Task 3 replaces the stop).

- [ ] **Step 1: Failing tests.**
  - Asserts:
    - `col_top - 0 <= 215` (column length, printed lying down)
    - Print heights: `base_t <= 120`; `col[3] - col[2] + boss <= 120`; `arm_t <= 120`
    - `key[2] <= 0.2`
  - Checks:
    - `["column","base","touch"]` (key seated)
    - `["top_arm","column","touch"]`
    - `["rear_cover","column","touch"]`
    - `["hw_rod","base","<=",0.05]`
    - `["hw_rod","top_arm","<=",0.05]`
    - `["head","frame",">=",1]`
- [ ] **Step 2: Run** `bash check.sh`. Expected: FAIL (undefined parts / asserts).
- [ ] **Step 3: Implement.**
  - **Base:** slab with rod sockets, pad pocket and bench holes, plus a groove matching the column foot tongue, and 4 counterbored M5 holes from below.
  - **Column:** a U-channel from z 0 to `col_top`:
    - a foot tongue
    - M5 nut traps (support-free: slots open to the inside), 4 at the foot, 2–4 at the top
    - a top tongue into the arm
    - M3 insert bosses on the side-wall rear edges for the cover
  - **Rear cover:** a flat plate with M3 counterbores.
  - **Top arm:** a flat plate (z `col_top` to `arm_top`) with the rod bosses and grub holes, a groove over the column top, and M5 holes.
  - Tags: `print=` flat for base, cover and arm; for the column, the rotation that puts its front face (−y) down.
- [ ] **Step 4: Run** `bash check.sh` and `asm.py … --print --brief`. Expected: PASS; every frame part ≤ 120 mm tall; no part over the bed.
- [ ] **Step 5: Commit** `"v3.1: frame split into base, column, rear cover, top arm"`.

### Task 2: Fixed M6 axle, gear cluster, handle with hex sleeve

**Files:** Modify `v3/params.scad`, `v3/drive.scad`, `v3/hardware.scad`, `v3/drill_press_v3.scad`.

**Interfaces:**
- Consumes: column bosses (Task 1), `pinion_axis`, `slider_x`, `spr_*`, `pin_*`, `gear_phase`, `spr_phase`.
- Produces:
  - Params: `axle_d = 6`, `axle_len >= 100`, `hex_drive = 12` (A/F, handle sleeve into the cluster socket), `hex_depth = 8`, `cluster_x = [slider_x - spr_b/2 - hub, pin_w/2]`
  - Functions: `bearing_p()` (MPa), `hex_shear()` (MPa)
  - Modules: `gear_cluster()`, `handle_hub()` (rewritten, with a sleeve from the hub through the +x boss into the cluster socket), `hw_axle()` (M6 bolt + 2 nuts)
  - `shaft` and `stop_ring` are removed; the part id `gear_pair` becomes `gear_cluster`.

- [ ] **Step 1: Failing tests.**
  - Asserts:
    - `bearing_p() <= 5`
    - `hex_shear() <= 8`
    - `axle_len >= 100`
    - Main-pinion root clears the hex socket by ≥ 2 mm
  - `checks`:
    - `["gear_cluster","head","<=",0.3]`
    - `["gear_cluster","spring_slider","<=",0.3]`
    - `["handle_hub","gear_cluster","<=",0.3]`
    - `["handle_hub","column","<=",0.3]`
    - `["gear_cluster","column",">=",0]`
    - `["hw_axle","column","<=",0.3]`
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement.**
  - **Gear cluster:** printed flat. Ø6.3 bore, −x hub up to the −x wall inner face, hex socket on the +x face, same tooth phases as v3.
  - **Handle:** printed flat. Ø6.3 bore, hex sleeve from the hub (x 50) to the socket. The bolt head bears on the hub's outer face.
  - **Column +x boss:** bore sized for the hex sleeve's round journal section. Put a round section on the sleeve where it passes the wall.
  - **Hardware:** M6 bolt modelled from x −34 to 64 (head at +x), plus the nut and jam nut at −x.
- [ ] **Step 4: Run** `bash check.sh`. Expected: PASS, with the gear meshes unchanged (sections at x = 0 and x = slider_x, mid pose).
- [ ] **Step 5: Commit** `"v3.1: fixed M6 axle, printed gear cluster driven by the handle's hex sleeve"`.

### Task 3: Depth collar on the rod + scale

**Files:** Modify `v3/params.scad`, `v3/drive.scad` (or a new `v3/stop.scad`), `v3/head.scad` (pointer), `v3/frame.scad` (scale on the column side face).

**Interfaces:**
- Produces:
  - `collar_z(depth)`: collar top so the head bottom touches it at that depth. The model sets depth = `travel_len` at `down`.
  - Modules: `depth_collar()` (split collar on the left rod, M5 clamp), `scale_ticks()` (on the column's −x side face, 1 mm ticks, 5/10 mm longer, engraved 0.6 deep), and a head pointer.
  - Params: `collar_hold = mu * clamp_n * 2` (N, both faces), `rack_force = 30 * spoke_r / pin_r` (N).
- [ ] **Step 1: Failing tests.**
  - Asserts:
    - `collar_hold >= 3 * rack_force`
    - The scale range covers 0–40 mm of plunge
  - `checks`: pose `down` → `["depth_collar","head","touch"]`; otherwise `["depth_collar","head",">=",1]`. Plus `["depth_collar","hw_rod","<=",0.3]`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement.** The collar is printed flat, with a teardrop M5 hole and a split along y. The pointer is a 45°-supported fin on the head's −x side reaching the scale. The ticks are grooves on a face printed vertical in the column's print orientation (the −x face).
- [ ] **Step 4: Run** `bash check.sh`. Expected: PASS.
- [ ] **Step 5: Commit** `"v3.1: rod-collar depth stop with scale on the column"`.

### Task 4: Verification, print set, viewer, README

- [ ] **Step 1: Run** `asm.py … --check --clash --walls 1.2 --print --bom --brief` (all variants) and `validate_stl.py stl/*.stl`. Expected: no new FAIL classes beyond the documented artefacts (tooth tips, knife edges); no part over 120 mm tall.
- [ ] **Step 2:** Refresh `stl/` and `validation_report.json`; run `--html` and `--log "v3.1: …"`.
- [ ] **Step 3: README.**
  - Print list with orientations and the reason for each.
  - BOM with every screw and nut, and counts asserted in params.
  - Assembly order: base + column bolted, then the slider/spring/cluster through the open back, then the axle and handle, then the cover, then the head, rods and arm, then the collar.
  - Print-rule audit.
- [ ] **Step 4:** Update the published viewer: new part list, explode vectors per frame part, axle and collar.
- [ ] **Step 5: Commit and push.**
