// Bench drill press — assembly. Tables read by common/skills/openscad/scripts/asm.py
include <params.scad>
include <frame.scad>
include <hardware.scad>

part = "all";
parts = [
  ["base","Base","PLA",[0,0,-30],"print=auto"],
  ["hw_rod","Rod Ø8×250","Robu chrome rod, cut from 500 mm",[0,0,0],"pieces=2"]
];
checks = [
  ["hw_rod","base","<=",0.05]
];
report = [ ["base w", base_w], ["base d", base_d], ["rod top", rod_top_z] ];
module pick(n){ if(part=="all"||part==n) children(); }
pick("base") base();
pick("hw_rod") hw_rods();
