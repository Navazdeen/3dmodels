# bench_drill_press design log

Kept by the openscad skill beside the model. Read it before changing the design; add to it as you go.
Facts under each version are written by asm.py --log; the rest is notes from the conversation.

## What it is
- (what the thing does, its main parts, the hardware it uses)

## Decisions
- (what was decided and why, with the version or print that settled it)

## Tried and rejected
- (what was tried, why it was dropped, so nobody brings it back)

## Open questions
- (what still has to be settled, and what would settle it)

## How the user works
- (preferences: printer and materials, supports, look and feel, how they test)

## Versions

### bench_drill_press - 2026-11-13 19:40 (rev 217742e)

**Changed:** v1: first complete model. Compact (220 mm tall, 140x160 base), 2x216 mm rods, printed LM8UU-size sleeves, vertical dovetail tool holders (775/555/iron), 4:1 lever on M8 pivot, kit extension springs on printed pegs, depth-stop collar. Motor/iron sizes UNVERIFIED.

Run:
- [up] report: base w 140 | base d 160 | rod top 198 | rod cut length 216 | overall h 220 | pivot [56,72,140] | lever angle 28.393 | spring stretch d[12, 15, 18] [11.412,14.265,17.119] | spring len now 45.4 | tool 775 | holder_z 45 | tip z 83.5

**Prints and feedback:** (what the user reported about this version)


### bench_drill_press - 2026-11-13 20:02 (rev 66fb0a5)

**Changed:** v2 (after final review): kickstand spring lever-tail -> base post (asserted torque & stretch), carriage 88 tall (sleeve pitch 64), M5x40 pin on printed spacer, rod clamp relief jaws, crush-rib knob pockets + 5 mm key holes, bridge top-stop bumpers, counterweight removed. Rods 2x232, height 236.

Run:
- [up] report: base w 140 | base d 160 | rod top 214 | rod cut length 232 | overall h 236 | pivot [56,72,156] | lever angle 28.393 | return torque / need (N·mm) [273.509,221.634] | kickstand len / free [77.539,75] | tool 775 | holder_z 45 | tip z 83.5

**Prints and feedback:** (what the user reported about this version)

