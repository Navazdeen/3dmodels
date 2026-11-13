# Skills

3D-modeling and 3D-printing guideline skills, vendored (copied, not linked)
so the repo is self-contained. Approved by the owner on 2026-11-13.

| Folder | Source | Commit | License | Used for |
|---|---|---|---|---|
| `openscad/` | github.com/pthompson8594/openscad-skill (`openscad/`) | 474547b | MIT-0 | OpenSCAD workflow, ISO 286 fits, hardware lookup, assembly clash/motion checks, rendering |
| `3d-print-designer/` | github.com/wilsonwaters/3d-printing (`.claude/skills/3d-print-designer/`) | f5e18a1 | MIT | FDM design principles, material (PLA/PETG/ABS) rules, print orientation, design review |

Rejected: `flowful-ai/cad-skill` (CadQuery/Python, not OpenSCAD; its print
checks already live in `common/tools/validate_stl.py`), `swh/openscad-skill`
(another author's BOSL2 house style).

Rule: no other skill is downloaded or used without the owner's explicit OK.
Setup: `bash common/skills/openscad/scripts/setup.sh` (installs OpenSCAD).
