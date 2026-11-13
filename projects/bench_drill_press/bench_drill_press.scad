// Bench drill press — assembly. Tables read by common/skills/openscad/scripts/asm.py
include <params.scad>
include <frame.scad>
include <carriage.scad>
include <hardware.scad>

part = "all";
parts = [
  ["base","Base","PLA",[0,0,-30],"print=auto"],
  ["top_bridge","Top bridge","PLA",[0,0,40],"print=x180"],
  ["spine","Spine","PLA",[0,30,0],"print=x90"],
  ["carriage","Carriage","PLA",[0,-40,0],"print=auto"],
  ["sleeve0","Sleeve 0 (printed, LM8UU size)","PLA",[0,0,0],"flex=carriage","print=auto"],
  ["sleeve1","Sleeve 1 (printed, LM8UU size)","PLA",[0,0,0],"flex=carriage","print=auto"],
  ["sleeve2","Sleeve 2 (printed, LM8UU size)","PLA",[0,0,0],"flex=carriage","print=auto"],
  ["sleeve3","Sleeve 3 (printed, LM8UU size)","PLA",[0,0,0],"flex=carriage","print=auto"],
  ["hw_rod","Rod Ø8","Robu chrome rod, cut from one 500 mm",[0,0,0],"pieces=2"]
];
checks = [
  ["hw_rod","base","<=",0.05],
  ["hw_rod","top_bridge","<=",0.05],
  ["spine","base","touch"],
  ["spine","top_bridge","touch"],
  ["carriage","hw_rod",">=",0.3],
  ["carriage","base",">=",3],
  ["carriage","top_bridge",">=",3],
  ["carriage","spine",">=",2],
  ["sleeve0","hw_rod",">=",0],
  ["sleeve1","hw_rod",">=",0],
  ["sleeve2","hw_rod",">=",0],
  ["sleeve3","hw_rod",">=",0]
];
report = [ ["base w", base_w], ["base d", base_d], ["rod top", rod_top_z], ["rod cut length", rod_len], ["overall h", overall_h], ["pivot", pivot_pos] ];
module pick(n){ if(part=="all"||part==n) children(); }
pick("base") base();
pick("top_bridge") top_bridge();
pick("spine") spine();
pick("carriage") carriage();
for (i = [0:3]) pick(str("sleeve", i)) sleeve_at(i);
pick("hw_rod") hw_rods();
