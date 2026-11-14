# Bench Drill Press v3 — Design ("fewer, smarter parts")

Status: **approved by owner 2026-11-14.** Supersedes v2 (`design.md`, kept as the record of v1/v2).

## 1. Intent

Same job as before: one compact, mostly-printed bench press on the owner's
Kobra 2 Neo for **PCB drilling** (555/775 + chuck, 0.6–1.0 mm carbide) and
**heat-set inserts** (60 W pen iron).

The redesign is the owner's request: think like a product designer, borrow
from proven products, and replace part count with smart geometry. v2 works
on paper but has ~25 printed parts, ~20 screws and an off-centre lever that
caused twist and spring problems.

Prior art that shaped v3:
- Heat-set insert presses (Stealth Press 1S/ZERO, Adafruit press, MakerWorld
  MGN12 press): one stiff guide, tool mounted straight on the slide, few parts.
- Proxxon MB 140/MB 200 drill stands: 20 mm column, **43 mm collar**, 40 mm
  travel, **rack-and-pinion feed with return spring, depth stop with scale**.
- Zezo-style printed PCB presses: fully printed slide, lever, accept some play.

## 2. Goals / non-goals / anti-goals

Goals
- **No play in the slide** without bought linear bearings or rails.
- **Feed force on the spindle centreline** (no twisting moment from the drive).
- **About 10 printed parts, fewer than 10 screws.**
- Head returns by itself; depth stop that reads in mm.
- Tool swap in under a minute with one screw.

Non-goals: X/Y table, motor speed control, iron temperature control.

Anti-goals
- Buying a linear rail (₹1,600–4,200: rejected by owner as too costly).
- Any PLA within the iron's hot zone; slide clearance that snaps 0.6 mm bits.
- Parts that need supports or don't fit 220 × 220 × 250 mm.

## 3. Decisions (owner, 2026-11-14)

| Topic | Decision |
|---|---|
| Guide | **Preloaded V-slide on the two Ø8 rods.** The head bears on the left rod in a 90° V and on the right rod with one flat pad. A printed flexure presses both rods into those contacts, so there is no clearance and wear self-compensates. |
| Feed | **Rack and pinion on the centreline.** Rack printed into the back of the head, between the rods; pinion turned by a 3-spoke handle. |
| Tool mount | **One 43 mm "Euro collar" split ring** on the head + printed adapter sleeves (775 shim, 555 sleeve, iron sleeve). Tool height is set by sliding the tool in the ring. |
| Rods | Unchanged purchase: one Ø8 × 500 mm chrome rod (Robu, ~₹288), cut in two. |

## 4. Claude's calls (owner may override)

| Topic | Call | Reason |
|---|---|---|
| Frame | **One-piece printed C-frame**: base, upright column and top arm in one print (≈230 mm tall, fits the 250 mm Z). Rods drop through the top arm into blind holes in the base, retained by one M3 each. | Removes bridge, spine and 8 screws; one rigid part. |
| Pinion shaft | **Printed** pinion + shaft + spring drum as one part, turning in printed bores in the column. Hex shaft ends take the handle hub and the stop ring. | No M8 bolt needed; nothing to key. |
| Gearing | Module 1.5, 14 teeth → pitch radius 10.5 mm; handle spokes ≈ 60 mm → ≈ 5.7 : 1 feel; one handle turn ≈ 66 mm of travel; 40 mm travel ≈ 220°. | Fine feel for small bits; teeth large enough for PLA. |
| Return | **Kickstand spring on a printed spring slider**: a small pinion (r ≈ 4–5 mm) on the same shaft drives a short printed rack-slider guided in a channel in the column; the spring pulls the slider. Gearing shrinks the spring's stretch to ≈ 15–19 mm for 40 mm of travel. | No cord to buy or fray; the kickstand spring is too stiff/short to hang off the head directly. |
| Depth stop | Stop ring clamped (1 M3) on a **round** section of the pinion shaft, continuously adjustable, with a printed mm scale against a fixed lug on the column. | Replaces rod collar, thumbwheel and M5; reads depth directly. A hex seat would only allow 11 mm steps. |
| Iron sleeve | **PLA only** (owner has no PETG): sleeve made longer with a larger slotted air-gap section, and **≥ 15 mm** of air to the hot zone (not 10). Treat it as a replaceable part. | Insert-press makers warn PLA deforms near irons. |
| Contact layout & preload | The feed reaction always tips the head the same way (front up, rear down: the rack sits ≈ 58 mm behind the tool). **Rigid V/pad seats are placed on the sides that tipping loads** (top contacts in front of the rods, bottom contacts behind them); the flexure gibs sit opposite and carry only a light preload of ≈ 3 N each. One M3 per flexure re-tightens after PLA creep. | Feed loads go into rigid plastic, not springs, so no lift-off; light preload keeps friction ≈ 6 N (good feel for 0.6 mm bits, and a spring we can actually fit returns the head). |

## 5. Architecture (sketch, side view, tool in front)

```
            ┌───────── top arm (rod tops, M3 retain) ─────────┐
            │                                                  │
   handle ──●══ pinion + drum (printed shaft, through column)  │
   (right)  │   ▲ rack on head back                           column (hollow,
            │ ┌─┴──────────────┐                               spring inside)
            │ │  HEAD           │ V on left rod, pad on right rod,
   43 mm ───┼─┤  split ring  ◯  │ flexure gib behind each rod
   collar   │ └────────────────┘
            │        │ tool (775 / 555 / iron sleeve)
            │        ▼ 40 mm clearance
            └────────── base (work pad pocket) ─────────────────┘
```

Printed parts (target ≤ 10): C-frame · head (V, pad, flexures, rack, 43 mm
ring) · pinion shaft (main + spring pinion) · spring slider · handle hub with
3 spokes · depth-stop ring · 775 shim · 555 sleeve · iron sleeve ·
preload test coupon.

## 6. Hardware (owner approval status)

| Item | Qty | Status |
|---|---|---|
| Ø8 × 500 mm chrome rod, cut to 2 pieces | 1 | approved |
| Bike kickstand spring | 1 | approved |
| M5 × ~25 + insert (43 mm ring clamp) | 1 | approved type (M5) |
| M3 + inserts (rod retention 2, preload adjust 2, stop ring 1) | ~5 | approved type (M3) |
| Motor face screws | 2+2 | approved (may be unused: ring clamps the body) |
| M8 pivot bolt, M5 lock/pin/stop screws, extra M3s from v2 | — | no longer needed |

## 7. Checks the model must pass (asserts / asm checks)

- Kinematics: head travels 40 mm with no clash; rack stays engaged over the
  full travel plus 2 mm each end; stop ring range covers 0–40 mm.
- Return: spring-pinion torque ≥ 1.25 × (head weight + slide friction) ×
  rack pitch radius, at the top; spring extension ≤ its allowed maximum at
  the bottom (kickstand values UNVERIFIED).
- Slide: under a 50 N feed load, the moment F × rack offset ÷ contact
  spacing is carried by rigid seats; flexure preload ≥ the reverse moment
  from the return spring and head weight.
- Reach & clearance: tip reaches the work pad at full plunge and clears
  ≥ 40 mm at the top, for each tool, using the slide-in-ring height range.
- Heat: iron sleeve keeps ≥ 15 mm of air to the hot zone (PLA).
- Printability: every part one body, fits the bed, no supports
  (validate_stl + asm print checks), C-frame top arm on 45° gussets.
- Part count: printed ≤ 10, screws ≤ 8 (excluding motor face screws).

## 8. Measure before printing (UNVERIFIED in the model)

775/555 body diameters, chuck size, iron handle diameter & hot-zone length,
kickstand spring length / rate / pre-tension, head weight. Print the preload
test coupon first (V + pad + flexure on a short rod) to set the flexure gap.

## 9. Left to the builder

Exact V-pad lengths and spacing, flexure shape, column wall thickness, gear
tooth profile details, cord routing, scale graduation style, fillets.

## 10. Builder check (2026-11-14) — resolved

- Preload friction vs return spring → contact layout puts feed loads on rigid seats; flexure preload ≈ 3 N (Claude's call).
- Off-centre (fore-aft) feed moment → same fix, plus an assert in §7.
- Cord strength / approval → cord removed; spring drives a printed slider rack (Claude's call).
- Depth stop on a hex → moved to a round shaft section (Claude's call).
- Units in the return check → corrected.
- PETG availability → owner: PLA only; air gap raised to 15 mm (see §4).
