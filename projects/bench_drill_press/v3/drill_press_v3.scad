// Bench drill press v3 — assembly. Tables read by common/skills/openscad/scripts/asm.py
include <params.scad>
include <frame.scad>
include <head.scad>
include <drive.scad>
include <sleeves.scad>
include <hardware.scad>

part = "all";
parts = concat([
  ["base","Base","PLA",[0,0,-40],"print=auto","group=frame"],
  ["column","Column (U-channel)","PLA",[0,60,0],"print=x90","group=frame"],
  ["rear_cover","Rear cover","PLA",[0,110,0],"print=x-90","group=frame"],
  ["top_arm","Top arm","PLA",[0,0,60],"print=x180","group=frame"],
  ["head","Head (slide + rack + 43 mm ring)","PLA",[0,-40,0],"print=auto"],
  ["gear_cluster","Gear cluster (main + spring pinion)","PLA",[0,40,0],"print=y90"],
  ["hw_axle","M6x100 axle + nut + jam nut","",[-60,0,0],"flex=gear_cluster,handle_hub"],
  ["spring_slider","Spring slider","PLA",[0,40,0],"print=auto"],
  ["handle_hub","Handle (3 spokes)","PLA",[40,0,0],"print=y90"],
  ["hw_spring","Bike kickstand spring (UNVERIFIED)","",[0,40,0],"flex=spring_slider,base"],
  ["depth_collar","Depth-stop collar","PLA",[-40,0,-30],"print=auto"],
  ["hw_foot_bolts","M5x16 socket + nut (base joint, nut fitted by hand)","",[0,0,-40],"pieces=4","group=frame"],
  ["hw_top_bolts","M5x16 socket + nut (arm joint, nut in a captive pocket)","",[0,0,60],"pieces=2","group=frame"],
  ["hw_collar_bolt","M5x25 socket + nut (depth collar)","",[-40,0,-30]],
  ["hw_rod","Rod Ø8","cut from one 500 mm rod",[0,0,0],"pieces=2","flex=head"]
], tool == "775" ? [["hw_motor","775 motor (UNVERIFIED size)","",[0,-60,0],"flex=head"], ["hw_chuck_bit","Chuck + bit"]]
 : tool == "555" ? [["sleeve_555","555 sleeve","PLA",[0,-60,0],"print=x180","flex=head"], ["hw_motor","555 motor (UNVERIFIED size)","",[0,-60,0],"flex=sleeve_555"], ["hw_chuck_bit","Chuck + bit"]]
 : [["sleeve_iron","Iron sleeve (PLA, replaceable)","PLA",[0,-60,0],"print=x180","flex=head"], ["hw_iron_handle","Pen iron handle (UNVERIFIED)","",[0,-60,0],"flex=sleeve_iron"], ["hw_iron_hot","Iron hot zone"]]);
checks = concat([ ["hw_rod","base","<=",0.05], ["hw_rod","top_arm","<=",0.05], ["column","base","touch"], ["top_arm","column","touch"], ["rear_cover","column","touch"],
  ["head","hw_rod","<=",0], ["head","frame",">=",1],
  ["gear_cluster","head","<=",0.3], ["gear_cluster","spring_slider","<=",0.3], ["handle_hub","gear_cluster","<=",0.3], ["gear_cluster","column",">=",0], ["gear_cluster","column","<=",0.5], ["hw_axle","column","<=",0.3],
  ["spring_slider","frame","<=",0.5], ["handle_hub","head",">=",1], ["handle_hub","hw_rod",">=",2], ["handle_hub","column","<=",0.3]], tool == "iron" ? [["sleeve_iron","hw_iron_hot",">=",iron_air_gap], ["frame","hw_iron_hot",">=",1], ["head","hw_iron_hot",">=",iron_air_gap], ["sleeve_iron","head","<=",0.3]]
  : tool == "555" ? [["sleeve_555","head","<=",0.3], ["hw_chuck_bit","frame",">=",0]] : [["hw_motor","head","<=",0.6], ["hw_chuck_bit","frame",">=",0]],
  pose == "down" ? [["depth_collar","head","touch"]] : [["depth_collar","head",">=",1]], [["depth_collar","hw_rod","<=",0.3], ["hw_top_bolts","column","<=",0.2], ["hw_top_bolts","rear_cover",">=",0.3], ["hw_foot_bolts","base","touch"], ["hw_top_bolts","top_arm","touch"], ["hw_collar_bolt","head",">=",1], ["hw_collar_bolt","depth_collar","touch"]]);
report = [ ["frame h", frame_h(), "column len", col_len], ["column bending MPa @50 N", col_bend_stress(50)], ["printed / screws", [n_printed, n_screws]], ["depth collar hold N / 3x rack", [collar_hold, 3 * rack_force]], ["rod cut length", rod_len], ["pinion axis", pinion_axis], ["gib k / gap / stress", [gib_k, gib_gap, gib_stress()]], ["tip moment 5 N / 50 N", [tip_moment(5), tip_moment(50)]], ["spring N top/bottom", [ks_force(0), ks_force(travel_len)]], ["return torque / need", [ret_torque(0), (head_mass*9.81 + friction) * pin_r]], ["tool / s / tip", [tool, tool_s, tip_z(plunge, tool_s)]] ];
module pick(n){ if(part=="all"||part==n) children(); }
pick("base") base();
pick("column") column();
pick("rear_cover") rear_cover();
pick("top_arm") top_arm();
pick("head") head();
pick("gear_cluster") gear_cluster();
pick("hw_axle") hw_axle();
pick("spring_slider") spring_slider();
pick("handle_hub") handle_hub();
pick("hw_spring") hw_spring();
pick("depth_collar") depth_collar();
pick("hw_foot_bolts") hw_joint_bolts(cjoint[1] / 2);
pick("hw_top_bolts") hw_joint_bolts(col_top - cjoint[1] / 2, top_bolt_y);
pick("hw_collar_bolt") hw_collar_bolt();
pick("hw_rod") hw_rods();
pick("sleeve_555") sleeve_555();
pick("sleeve_iron") sleeve_iron();
pick("hw_motor") hw_motor();
pick("hw_chuck_bit") hw_chuck_bit();
pick("hw_iron_handle") hw_iron_handle();
pick("hw_iron_hot") hw_iron_hot();
