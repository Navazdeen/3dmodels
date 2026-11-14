// Bench drill press v3 — assembly. Tables read by common/skills/openscad/scripts/asm.py
include <params.scad>
include <frame.scad>
include <head.scad>
include <drive.scad>
include <hardware.scad>

part = "all";
parts = [
  ["c_frame","C-frame","PLA",[0,0,0],"print=auto"],
  ["head","Head (slide + rack + 43 mm ring)","PLA",[0,-40,0],"print=auto"],
  ["shaft","Pinion shaft","PLA",[0,0,0],"print=y90"],
  ["gear_pair","Main pinion","PLA",[0,30,0],"print=y90"],
  ["spring_slider","Spring slider","PLA",[0,40,0],"print=auto"],
  ["handle_hub","Handle (3 spokes)","PLA",[40,0,0],"print=y90"],
  ["stop_ring","Depth-stop ring","PLA",[-40,0,0],"print=y-90"],
  ["hw_spring","Bike kickstand spring (UNVERIFIED)","",[0,40,0],"flex=spring_slider,c_frame"],
  ["hw_rod","Rod Ø8","cut from one 500 mm rod",[0,0,0],"pieces=2","flex=head"]
];
checks = concat([ ["hw_rod","c_frame","<=",0.05], ["head","hw_rod","<=",0], ["head","c_frame",">=",1],
  ["gear_pair","head","<=",0.3], ["shaft","spring_slider","<=",0.3], ["shaft","c_frame","<=",0.3],
  ["spring_slider","c_frame","<=",0.5], ["handle_hub","head",">=",1], ["handle_hub","hw_rod",">=",2]], pose == "down" ? [["stop_ring","c_frame","touch"]] : [["stop_ring","c_frame","<=",0.05]]);
report = [ ["frame h", frame_h()], ["rod cut length", rod_len], ["pinion axis", pinion_axis], ["gib k / gap / stress", [gib_k, gib_gap, gib_stress()]], ["tip moment 5 N / 50 N", [tip_moment(5), tip_moment(50)]], ["spring N top/bottom", [ks_force(0), ks_force(travel_len)]], ["return torque / need", [ret_torque(0), (head_mass*9.81 + friction) * pin_r]] ];
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
