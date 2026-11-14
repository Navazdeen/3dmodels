// Bench drill press v3 — assembly. Tables read by common/skills/openscad/scripts/asm.py
include <params.scad>
include <frame.scad>
include <hardware.scad>

part = "all";
parts = [
  ["c_frame","C-frame","PLA",[0,0,0],"print=auto"],
  ["hw_rod","Rod Ø8","cut from one 500 mm rod",[0,0,0],"pieces=2"]
];
checks = [ ["hw_rod","c_frame","<=",0.05] ];
report = [ ["frame h", frame_h()], ["rod cut length", rod_len], ["pinion axis", pinion_axis] ];
module pick(n){ if(part=="all"||part==n) children(); }
pick("c_frame") c_frame();
pick("hw_rod") hw_rods();
