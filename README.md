# 3dmodels

Parametric OpenSCAD models for 3D printing.

```
common/                  shared by every project
  openscad/              reusable OpenSCAD modules (fillets, inserts, screw holes...)
  skills/                3D-modeling / 3D-printing guideline skills
  tools/validate_stl.py  printability checker (walls, overhangs, bridges, bed contact)
projects/
  kobra2neo_nozzle_cam/  nozzle camera mount for Anycubic Kobra 2 Neo
  bench_drill_press/     3D-printed bench drill press (PCB drilling + heat-set inserts); current model in v3/
```

Each project folder holds its `.scad` source, exported `stl/`, previews and
validation report. Include shared code with
`use <../../common/openscad/<file>.scad>`.

Validate a part: `python3 common/tools/validate_stl.py projects/<p>/stl/*.stl`
