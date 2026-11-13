// Bench drill press — assembly. Tables read by common/skills/openscad/scripts/asm.py
include <params.scad>
include <frame.scad>
include <carriage.scad>
include <lever.scad>
include <holders.scad>
include <hardware.scad>

part = "all";
parts = concat([
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
  ["hw_rod","Rod Ø8","Robu chrome rod, cut from one 500 mm",[0,0,0],"pieces=2"],
  ["lock_knob","Holder lock knob","PLA",[0,40,0],"print=auto"],
  ["hw_lock_screw","M5 holder lock screw"]
], tool == "775" ? [["holder_775","775 motor holder","PLA",[0,-40,0],"print=x-90"], ["hw_motor","775 motor (UNVERIFIED size)"], ["hw_chuck_bit","Chuck + bit"]]
 : tool == "555" ? [["holder_555","555 motor holder","PLA",[0,-40,0],"print=x-90"], ["hw_motor","555 motor (UNVERIFIED size)"], ["hw_chuck_bit","Chuck + bit"]]
 : [["holder_iron","Iron holder","PLA",[0,-40,0],"print=x-90"], ["iron_strap","Iron clamp strap","PLA",[0,-70,0],"print=auto"],
    ["hw_iron_handle","Pen iron handle (UNVERIFIED size)"], ["hw_iron_hot","Iron hot zone"], ["hw_strap_screws","2 x M3x30 strap screws","",[0,0,0],"pieces=2","flex=holder_iron,iron_strap"]]);
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
],
  [["hw_lock_screw","carriage","<=",0.8], ["lock_knob","carriage",">=",0.3]],
  tool == "iron" ? [["holder_iron","hw_iron_hot",">=",iron_air_gap], ["iron_strap","hw_iron_hot",">=",iron_air_gap],
                    ["holder_iron","carriage","<=",0.4], ["hw_lock_screw","holder_iron","touch"], ["holder_iron","base",">=",1]]
  : [[str("holder_", tool),"carriage","<=",0.4], ["hw_lock_screw",str("holder_", tool),"touch"],
     ["hw_chuck_bit","base",">=",0], [str("holder_", tool),"base",">=",1], [str("holder_", tool),"lever",">=",1]],
  pose == "down" ? [["hw_stop_screw","carriage","touch"]] : [["hw_stop_screw","carriage",">=",19]]);
report = [ ["base w", base_w], ["base d", base_d], ["rod top", rod_top_z], ["rod cut length", rod_len], ["overall h", overall_h], ["pivot", pivot_pos], ["lever angle", lever_angle(plunge)], [str("spring stretch d", spring_d), [for (d = spring_d) spring_stretch(d)]], ["spring len now", spring_len(spring_d[spring_default], plunge)], ["tool", tool], ["holder_z", holder_z], ["tip z", tip_z(holder_z, plunge)] ];
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
pick("lock_knob") lock_knob();
pick("hw_lock_screw") hw_lock_screw();
pick("holder_775") holder_motor(m775_d, m775_len, m775_screw, m775_boss);
pick("holder_555") holder_motor(m555_d, m555_len, m555_screw, m555_boss);
pick("holder_iron") holder_iron();
pick("iron_strap") iron_strap();
pick("hw_motor") hw_motor();
pick("hw_chuck_bit") hw_chuck_bit();
pick("hw_iron_handle") hw_iron_handle();
pick("hw_iron_hot") hw_iron_hot();
pick("hw_strap_screws") hw_strap_screws();
