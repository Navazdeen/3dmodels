// Bench drill press — assembly. Tables read by common/skills/openscad/scripts/asm.py
include <params.scad>
include <frame.scad>
include <hardware.scad>

part = "all";
parts = [
  ["base","Base","PLA",[0,0,-30],"print=auto"],
  ["top_bridge","Top bridge","PLA",[0,0,40],"print=x180"],
  ["spine","Spine","PLA",[0,30,0],"print=x90"],
  ["hw_rod","Rod Ø8","Robu chrome rod, cut from one 500 mm",[0,0,0],"pieces=2"]
];
checks = [
  ["hw_rod","base","<=",0.05],
  ["hw_rod","top_bridge","<=",0.05],
  ["spine","base","touch"],
  ["spine","top_bridge","touch"]
];
report = [ ["base w", base_w], ["base d", base_d], ["rod top", rod_top_z], ["rod cut length", rod_len], ["overall h", overall_h], ["pivot", pivot_pos] ];
module pick(n){ if(part=="all"||part==n) children(); }
pick("base") base();
pick("top_bridge") top_bridge();
pick("spine") spine();
pick("hw_rod") hw_rods();
