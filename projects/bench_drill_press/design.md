# Bench Drill Press — Design

Status: draft for owner approval (2026-11-13). Builder check done, owner answers merged.

## 1. Intent

One small bench press, printed in PLA on the owner's Kobra 2 Neo, with a
swappable head for two jobs:

1. **PCB drilling**: 555 or 775 DC motor with chuck, 0.6–1.0 mm carbide bits.
2. **Heat-set inserts**: 60 W adjustable pen soldering iron whose tip is
   modified to hold brass inserts.

Success looks like this: small carbide bits don't snap from wobble, inserts go
in straight and to the same depth every time, and changing tools takes
seconds without re-aligning anything.

## 2. Goals / non-goals / anti-goals

Goals
- Plunge stays perpendicular with very little play (it's the guide that saves
  carbide bits).
- Tool swap in seconds: the axis lands back centred and vertical. Height and depth get set again for each job.
- A depth stop that repeats, for insert depth and for not drilling into the
  base.
- Everything printed except the hardware approved in §6.

Non-goals (v1)
- An X/Y table or PCB alignment fixture (separate project later).
- Motor speed control or electronics. The owner already powers the motors.
- Iron temperature control. The iron has its own dial.

Anti-goals (a failure even if it "works")
- A slide wobbly enough to snap 0.6 mm carbide bits.
- Any PLA part touching or near the iron's hot barrel. PLA softens at about
  55–60 °C.
- Parts that don't fit the Kobra 2 Neo bed or need heavy supports.

## 3. Constraints (fixed)

| Item | Value | Source |
|---|---|---|
| Printer | Anycubic Kobra 2 Neo, 220 × 220 × 250 mm | owner |
| Material | PLA (all parts) | owner |
| Guide rods | 2 × Ø8 mm chrome smooth rod, 320 mm, Robu | owner chose |
| Sliding | printed PLA sleeves in LM8UU-sized pockets (Ø15 × 24 mm) so real LM8UU can drop in later | owner chose |
| Work clearance | up to 80 mm from base to tool tip, head fully up | owner chose |
| Height range | tool holder slides in a **vertical** dovetail and locks at any height; the 40 mm plunge works from wherever it's set, so the tip can reach anything from the base surface up to 80 mm | owner chose (fix for builder-check issue) |
| Frame | rods act as the column + printed base, top bridge, 2-part back spine | owner chose |
| Tool swap | vertical dovetail + one thumb screw (sets height and locks) | owner chose |
| Plunge | lever arm on a bolt pivot | owner chose |
| Return | extension springs on the lever near the pivot; counterweight pocket as backup | Claude's call (owner: no preference) |
| Depth stop | one stop screw with a printed thumbwheel, reset for each job by touching the tip on the work; not remembered across tool swaps | owner chose |
| Hardware | nothing beyond §6 without owner approval | owner rule |

## 4. Approaches considered

**Guide**
- *Rods + printed LM8UU-ready sleeves* — **picked.** Cheap now, and real
  bearings can drop in later without reprinting.
- Rods + LM8UU from day one: least play, costs about ₹200 more.
- All-printed dovetail slide: no hardware, but 0.1–0.3 mm of play that grows
  with wear. It would snap small carbide bits.

**Frame**
- *Rods as the column + base + top bridge + back spine* — **picked.** Steel
  carries the stiffness, and every part is short enough to print.
- Rods only, no spine: the top bridge can twist under lever load.
- Printed box column: about 3× the filament, and the stacked joints can shift.

**Return**
- *Extension springs on the lever* — **picked.** Using the owner's 200-piece
  kit, each spring stretches only 10–15 mm because it sits near the pivot.
- Compression springs on the rods: none in the kit has an inside diameter of
  8.5 mm or more. Locally sold ones don't fit 8 mm rods either.
- Counterweight only: kept as a backup pocket on the lever.

## 5. Architecture

```
          lever ─────────●(pivot, top bridge)───┐ spring anchors
                         │                      │ (row of holes)
  ┌──── top bridge ──────┴──────┐               │
  │ rod clamp        rod clamp  │◄── back spine (2 parts, tied to base & bridge)
  │   ║                  ║      │
  │ ┌─╫──────────────────╫─┐    │
  │ │ sleeves  CARRIAGE  sleeves│ ── link to lever (slot + pin)
  │ │   [ dovetail socket ]│    │ ── depth-stop screw
  │ └──────────┬───────────┘    │
  │       tool holder           │
  │       (555 | 775 | iron)    │
  │            ▼  80 mm daylight│
  └─────────── base ────────────┘
```

Parts (all PLA):
1. **Base**: footprint ≤ 210 × 210 mm, rod sockets with clamp screws, spine
   mount, flat work area with a replaceable sacrificial pad under the spindle,
   and screw holes so it can be fixed to the bench.
2. **Top bridge**: rod clamps, lever pivot boss, spring anchor row, spine
   mount.
3. **Back spine**: 2 parts joined with a lap joint and screws. It ties the
   base to the top bridge so the top can't twist.
4. **Carriage**: 4 sleeve pockets (2 per rod), spaced as far apart as fits, at
   least 60 mm between centres on each rod. Each pocket has a slit and a
   squeeze screw to take up play. Also carries a vertical dovetail socket
   (long enough for at least 45 mm of holder height travel), the lever link
   pin, and the depth-stop screw.
5. **Printed sleeves** ×4: Ø15 mm outside × 24 mm long (LM8UU size), with a
   bore that slides on the 8 mm rod. Print several bore sizes as a test set
   and keep the one that slides with no play.
6. **Lever**: about 4:1 ratio, a handle you can grip comfortably, a slot to
   the carriage pin, a spring hole row near the pivot, and a counterweight
   pocket at the tail.
7. **Depth stop**: M5 screw through the carriage onto a stop pad on the base,
   turned by a printed thumbwheel, with a lock nut. Set for each job.
8. **Tool holders** (each has the dovetail key on the back):
   - **555 holder**: cradle for the 555 body plus its face screws.
   - **775 holder**: cradle for the 775 body plus its face screws.
   - **Iron holder**: split clamp on the *handle only* (adjustable range so
     different irons fit), an open air gap and a printed spacer between the
     clamp and the hot barrel, and nothing printed within the hot zone.
9. **Knobs**: printed knob for the dovetail thumb screw.

Shared geometry:
- **Spindle axis**: centred between the rods, 70 mm in front of the rod plane
  (Claude's call, to give reach onto a PCB).
- **Travel**: 40 mm plunge.
- The spindle or iron axis must be perpendicular to the base, and stay
  aligned when tool holders are swapped.

## 6. Hardware list (approved 2026-11-13; anything new still needs owner approval)

| # | Item | Qty | Purpose | Status |
|---|---|---|---|---|
| H1 | Ø8 × 320 mm chrome smooth rod (Robu) | 2 | guide column | approved |
| H2 | 200-pc spring kit (MTRoyaldia, Amazon) — use ext. 7.14×50.8 or 7.93×44.4 | 1 kit | lever return | approved |
| H3 | M8 bolt + nyloc nut, length set by the lever boss (about 50–60 mm) | 1 | lever pivot | approved |
| H4 | M5 screw + heat-set insert | 1 | dovetail thumb screw | approved |
| H5 | M5 screw + nut | 1 | lever–carriage link pin | approved |
| H6 | M5 screw + nut/insert | 1 | depth stop | approved |
| H7 | M3 screws + heat-set inserts | ~12 | rod clamps, spine joints, sleeve squeeze screws | approved |
| H8 | Motor face screws (usually supplied with 555 / 775) | 2 + 2 | motor mounting | approved |
| H9 | LM8UU linear bearing (optional upgrade) | 4 | if printed sleeves wobble | future |

Screw sizes are Claude's call and are meant to match the heat-set inserts the
owner already uses. See §8.

## 7. Verification

- OpenSCAD source in `projects/bench_drill_press/`. Use the vendored skills in
  `common/skills/` (`openscad`: fits, assembly clash and motion checks;
  `3d-print-designer`: PLA rules, print orientation, design review).
- Every part goes through `common/tools/validate_stl.py`: watertight, sits flat
  on the bed, walls ≥ 1.2 mm, overhangs ≤ 45°, bridges < 20 mm.
- Assembly check: no clashes across the full 40 mm plunge, 80 mm daylight
  confirmed, and the lever doesn't hit the frame.
- Every part fits within 220 × 220 × 250 mm in its print orientation.
- Height check: with the holder at its lowest setting and full plunge, the tip
  reaches the sacrificial pad. With it at its highest setting and the head up,
  there is at least 80 mm of clearance.

## 8. Dimensions to verify before modeling (owner measures)

These are standard sizes, but cheap motors and irons vary. Each will be
modeled as a parameter and checked against the owner's calipers:
- 555 body diameter, length, and face screw spacing and size (typical: about
  Ø35.8 mm, M3).
- 775 body diameter, length, and face screw spacing and size (typical: about
  Ø42 mm, M4 at about 29 mm).
- Pen iron handle: diameter at the grip, grip length, distance from the grip
  to the tip, and where the barrel starts getting hot.
- Heat-set insert sizes the owner already has (M3? M4? M5?).

## 9. Left to the builder

Print orientation per part, infill and wall counts, exact rod clamp style,
sleeve bore test values, fillet and chamfer sizes, the dovetail angle and
tolerance, the lever shape, and module structure in OpenSCAD.
