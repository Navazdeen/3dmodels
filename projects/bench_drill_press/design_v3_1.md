# Bench Drill Press v3.1 — Frame split + steel axle (amendment to design_v3.md)

Status: **approved by owner 2026-11-15** (M6 ≥ 100, partly threaded, available). Everything in design_v3.md still applies unless changed here.

## Why

The owner's review of v3:
- **Print risk.** The one-piece C-frame is a single 248 mm print, roughly 20 h (Guessing). A failure late in the print wastes the whole part. Several short prints each risk only themselves.
- **Strength.** One piece forces one orientation. The column printed upright puts its bending load *across* the layers, PLA's weak direction (3d-print-designer `material-pla.md`: never cycle-load across layers). Split parts can each be printed in the orientation that suits their load.
- **Shaft.** The printed shaft twists across its layers (about 11 MPa at worst). Owner has M3–M6 screws and nuts, so a steel axle is free.

## Decisions (owner, 2026-11-15)

| Topic | Decision |
|---|---|
| Frame | **4 parts**: base, column (U-channel: front wall + 2 side walls), rear cover, top arm |
| Axle | **M6 bolt** as the pinion axle; printed gears keyed to it |
| Hardware | M3–M6 screws and nuts from the owner's stock may be used; every one is listed in the BOM |

## Parts and orientation (Claude's calls)

| Part | Print orientation | Main load in use | Why the orientation |
|---|---|---|---|
| Base | Flat (as used) | Plate bending from the column and the work | Plate loads lie along the layers |
| Column (U-channel) | Lying on its front face | Bending along its height from the drilling reaction | Column length runs along the layers. Side walls print vertical, so bearing bosses are solid walls |
| Rear cover | Flat | Closes the box (torsion), carries the slider guides' rear support | Thin plate prints best flat |
| Top arm | Flat (upside down if needed) | Holds the rod tops; small bending | Plate, so it no longer needs 45° undersides |
| Gear cluster (main pinion + spring pinion) | Flat (gear axis vertical) | Tooth bending | Gears print flat: tooth loads lie along the layers |
| Handle | Flat | Spoke bending | Unchanged |
| Stop ring, head, slider, sleeves | As v3 | — | Unchanged |

Printed parts: base, column, cover, arm, head, gear cluster, slider, handle, depth-stop collar, 555 sleeve, iron sleeve = **11**, plus the preload coupon. Budget (replaces v3's ≤ 10 / ≤ 9): ≤ 11 printed, screws listed and asserted from the BOM (≈ 20). No print over about 120 mm tall (Guessing until modelled; asserted).

## Joints

- **Locate by keys, clamp by bolts.** Each frame joint has a tongue-and-groove (or a pair of printed dowel bosses) that sets the alignment. Bolts only clamp, so the rods stay parallel without hand-fitting.
- **Base ↔ column:** a column foot flange keyed into a groove in the base top, held by 4 × M5 from below into captured nuts in the column.
- **Column ↔ top arm:** the column top keyed into the arm's underside, held by 2–4 × M5 from above into captured nuts.
- **Column ↔ rear cover:** M3 screws into heat-set inserts along both side walls.
- Rods are retained as in v3 (blind sockets in the base, M3 grubs in the arm).

## Axle, gears and depth stop (revised after the builder check)

- **The M6 bolt is a fixed axle.** It doesn't turn. It goes through printed bearing bosses in both column side walls and is held by a nut and a jam nut outside the −x wall, finger-tight so nothing rotating gets clamped.
  - The gear cluster and the handle spin on the bolt's **smooth shank**. A standard part-threaded M6 (ISO 4014) works, with its threads only at the −x nut end.
  - Length is about 100 mm or more (from the nuts at about x −34 to the handle at about x +62).
- **Gear cluster** (main pinion m1.5 z14 + spring pinion m1 z12, as v3): one printed part, printed flat, with a Ø6.3 bore on the bolt. It has a **hex socket** in its +x face, and its −x hub runs against the −x wall to locate it axially.
- **Handle:** printed flat. Its **hex sleeve** passes through the +x wall bore, where it journals, and into the cluster's hex socket. The torque path is printed hex to printed hex, about 6 MPa at worst (30 N on a 60 mm spoke). The bolt head holds the handle on.
- **Depth stop:** a printed split collar on the left rod below the head, clamped with 1 × M5. It takes the rack force directly: needed about 170 N, held about 900 N by clamp friction (Likely). A pointer on the head reads a mm scale moulded on the column's side face. **The v3 stop ring and its pin arm are removed.**
- **Assembly:** with the rear cover off, drop in the slider and spring, then the cluster. Push the bolt through from +x, then fit the handle over the bolt into the cluster, then the nuts, then the cover.
## Unchanged from v3

Preloaded V-slide, rack geometry, the 43 mm ring and sleeves, kickstand spring + slider + top-stop ledge, depth scale, clearance and travel, PLA, the Kobra 2 Neo build volume.

## Checks the model must pass (in addition to v3's)

- Every printed part fits the bed in its stated orientation, and no part is taller than 120 mm in print orientation.
- Joint keys engage (touch), and no bolt passes through another part.
- Bearing pressure on the M6 in the bosses ≤ 5 MPa at the full rack + spring load.
- Gear cluster torque goes printed hex to printed hex; shear stress in the handle's hex sleeve ≤ 8 MPa at 30 N on the spoke.
- Depth collar: clamp friction ≥ 3 × the rack force at 30 N on the handle.
- The column's bending stress at 50 N drilling force is reported (expected small).
- Part and screw counts asserted against the BOM.

## Left to the builder

Exact key profiles and clearances, nut-trap orientation (support-free), cover screw count, and scale tick style.

## Builder check (2026-11-15), resolved

- **Nut can't reach the gears; jam-nut keying unreliable; stop ring can't hold on M6:** the axle is now fixed, torque goes through a printed hex, and the depth stop moved to a rod collar.
- **Bolt length:** about 100 mm or more. Owner to confirm stock.
- **Part / screw budget:** raised to 11 printed parts, screws listed and asserted from the BOM. Owner chose the split, which implies more joints.
