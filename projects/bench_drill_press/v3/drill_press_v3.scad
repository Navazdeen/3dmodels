// Bench drill press v3 — assembly. Tables read by common/skills/openscad/scripts/asm.py
include <params.scad>
include <frame.scad>
include <head.scad>
include <drive.scad>
include <sleeves.scad>
include <hardware.scad>

part = "all";
parts = concat([
  ["c_frame","C-frame","PLA",[0,0,0],"print=auto"],
  ["head","Head (slide + rack + 43 mm ring)","PLA",[0,-40,0],"print=auto"],
  ["shaft","Pinion shaft","PLA",[0,0,0],"print=y-90"],
  ["gear_pair","Main pinion","PLA",[0,30,0],"print=y90"],
  ["spring_slider","Spring slider","PLA",[0,40,0],"print=auto"],
  ["handle_hub","Handle (3 spokes)","PLA",[40,0,0],"print=y90"],
  ["stop_ring","Depth-stop ring","PLA",[-40,0,0],"print=y-90"],
  ["hw_spring","Bike kickstand spring (UNVERIFIED)","",[0,40,0],"flex=spring_slider,c_frame"],
  ["hw_rod","Rod Ø8","cut from one 500 mm rod",[0,0,0],"pieces=2","flex=head"]
], tool == "775" ? [["hw_motor","775 motor (UNVERIFIED size)","",[0,-60,0],"flex=head"], ["hw_chuck_bit","Chuck + bit"]]
 : tool == "555" ? [["sleeve_555","555 sleeve","PLA",[0,-60,0],"print=x180","flex=head"], ["hw_motor","555 motor (UNVERIFIED size)","",[0,-60,0],"flex=sleeve_555"], ["hw_chuck_bit","Chuck + bit"]]
 : [["sleeve_iron","Iron sleeve (PLA, replaceable)","PLA",[0,-60,0],"print=x180","flex=head"], ["hw_iron_handle","Pen iron handle (UNVERIFIED)","",[0,-60,0],"flex=sleeve_iron"], ["hw_iron_hot","Iron hot zone"]]);
checks = concat([ ["hw_rod","c_frame","<=",0.05], ["head","hw_rod","<=",0], ["head","c_frame",">=",1],
  ["gear_pair","head","<=",0.3], ["shaft","spring_slider","<=",0.3], ["shaft","c_frame","<=",0.3],
  ["spring_slider","c_frame","<=",0.5], ["handle_hub","head",">=",1], ["handle_hub","hw_rod",">=",2], ["handle_hub","c_frame","<=",0.05]], tool == "iron" ? [["sleeve_iron","hw_iron_hot",">=",iron_air_gap], ["c_frame","hw_iron_hot",">=",1], ["head","hw_iron_hot",">=",iron_air_gap], ["sleeve_iron","head","<=",0.3]]
  : tool == "555" ? [["sleeve_555","head","<=",0.3], ["hw_chuck_bit","c_frame",">=",0]] : [["hw_motor","head","<=",0.6], ["hw_chuck_bit","c_frame",">=",0]],
  pose == "down" ? [["stop_ring","c_frame","touch"]] : [["stop_ring","c_frame",">=",1]]);
report = [ ["frame h", frame_h()], ["rod cut length", rod_len], ["pinion axis", pinion_axis], ["gib k / gap / stress", [gib_k, gib_gap, gib_stress()]], ["tip moment 5 N / 50 N", [tip_moment(5), tip_moment(50)]], ["spring N top/bottom", [ks_force(0), ks_force(travel_len)]], ["return torque / need", [ret_torque(0), (head_mass*9.81 + friction) * pin_r]], ["tool / s / tip", [tool, tool_s, tip_z(plunge, tool_s)]] ];
module pick(n){ if(part=="all"||part==n) children(); }
pick("c_frame") c_frame();
pick("head") head();
pick("shaft") shaft();
pick("gear_pair") gear_pair();
pick("spring_slider") spring_slider();
pick("handle_hub") handle_hub();
pick("stop_ring") stop_ring();
pick("hw_spring") hw_spring();
pick("hw_rod") hw_rods();
pick("sleeve_555") sleeve_555();
pick("sleeve_iron") sleeve_iron();
pick("hw_motor") hw_motor();
pick("hw_chuck_bit") hw_chuck_bit();
pick("hw_iron_handle") hw_iron_handle();
pick("hw_iron_hot") hw_iron_hot();
