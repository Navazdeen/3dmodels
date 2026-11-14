# drill_press design log

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

### drill_press_v3 - 2026-11-14 18:34 (rev 890ce90)

**Changed:** v3: preloaded V-slide on Ø8 rods (rigid seats where the feed tips the head, 3.5 N flexure gibs), centre rack-and-pinion (m1.5, 30° PA), spring pinion cut into the shaft driving a kickstand-spring slider (top stop on its ledge), one-piece C-frame (248 mm), 43 mm split ring + 555/iron sleeves, depth-stop ring with 2 mm scale. 9 printed parts, 8 screws.

Run:
- [up] report: frame h 248 | rod cut length 245 | pinion axis [76.5,133] | gib k / gap / stress [3.84,0.911,13.125] | tip moment 5 N / 50 N [54.83,3024.83] | spring N top/bottom [48.121,78.597] | return torque / need [192.483,153.986] | tool / s / tip [775,10,40]

**Prints and feedback:** (what the user reported about this version)

