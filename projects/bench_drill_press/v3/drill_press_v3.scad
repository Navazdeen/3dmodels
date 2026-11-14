// Bench drill press v3 — assembly. Tables read by common/skills/openscad/scripts/asm.py
include <params.scad>
include <frame.scad>
include <head.scad>
include <hardware.scad>

part = "all";
parts = [
  ["c_frame","C-frame","PLA",[0,0,0],"print=auto"],
  ["head","Head (slide + rack + 43 mm ring)","PLA",[0,-40,0],"print=auto"],
  ["hw_rod","Rod Ø8","cut from one 500 mm rod",[0,0,0],"pieces=2","flex=head"]
];
checks = [ ["hw_rod","c_frame","<=",0.05], ["head","hw_rod","<=",0], ["head","c_frame",">=",1] ];
report = [ ["frame h", frame_h()], ["rod cut length", rod_len], ["pinion axis", pinion_axis], ["gib k / gap / stress", [gib_k, gib_gap, gib_stress()]], ["tip moment 5 N / 50 N", [tip_moment(5), tip_moment(50)]] ];
module pick(n){ if(part=="all"||part==n) children(); }
pick("c_frame") c_frame();
pick("head") head();
pick("hw_rod") hw_rods();
