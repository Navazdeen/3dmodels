// Bench drill press — assembly. Tables read by common/skills/openscad/scripts/asm.py
include <params.scad>
include <frame.scad>
include <carriage.scad>
include <lever.scad>
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
  ["lever","Lever","PLA",[30,0,0],"print=y-90"],
  ["cw_lid","Counterweight lid","PLA",[40,0,10],"print=y90"],
  ["collar","Depth-stop collar","PLA",[-30,0,0]],
  ["thumbwheel","Depth-stop thumbwheel","PLA",[-30,0,-10],"print=auto"],
  ["hw_pivot","M8 pivot bolt + nyloc"],
  ["hw_link_pin","M5 link pin"],
  ["hw_stop_screw","M5x20 depth-stop screw"],
  ["hw_spring","Kit extension spring 7.93x44.4","",[0,0,0],"flex=lever,top_bridge"],
  ["hw_rod","Rod Ø8","Robu chrome rod, cut from one 500 mm",[0,0,0],"pieces=2"]
];
checks = concat([
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
  ["sleeve3","hw_rod",">=",0],
  ["lever","top_bridge",">=",1],
  ["lever","spine",">=",1],
  ["lever","hw_rod",">=",1],
  ["lever","base",">=",1],
  ["lever","carriage",">=",1],
  ["collar","carriage",">=",1],
  ["hw_link_pin","carriage","<=",0.8],
  ["hw_link_pin","lever","<=",0.3],
  ["hw_pivot","lever","touch"],
  ["hw_pivot","top_bridge","touch"]
], variant == "down" ? [["hw_stop_screw","carriage","touch"]] : [["hw_stop_screw","carriage",">=",19]]);
report = [ ["base w", base_w], ["base d", base_d], ["rod top", rod_top_z], ["rod cut length", rod_len], ["overall h", overall_h], ["pivot", pivot_pos], ["lever angle", lever_angle(plunge)], ["spring stretch d12/16/20", [for (d = spring_d) spring_stretch(d)]], ["spring len now", spring_len(spring_d[spring_default], plunge)] ];
module pick(n){ if(part=="all"||part==n) children(); }
pick("base") base();
pick("top_bridge") top_bridge();
pick("spine") spine();
pick("carriage") carriage();
for (i = [0:3]) pick(str("sleeve", i)) sleeve_at(i);
pick("lever") lever();
pick("cw_lid") cw_lid();
pick("collar") collar();
pick("thumbwheel") thumbwheel();
pick("hw_pivot") hw_pivot();
pick("hw_link_pin") hw_link_pin();
pick("hw_stop_screw") hw_stop_screw();
pick("hw_spring") hw_spring();
pick("hw_rod") hw_rods();
