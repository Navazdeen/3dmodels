// Reference solids for bought parts (hw_). Not printed.
module hw_rods() { for (x = rod_x) translate([x, rod_y, -rod_socket_depth]) cylinder(d=rod_d, h=rod_len, $fn=48); }
module hw_pivot() {   // M8 bolt along +x: head left of the ear, nyloc right of the lever
  translate([0, pivot_pos[1], pivot_pos[2]]) rotate([0, 90, 0]) {
    translate([0, 0, ear_x[0] - 5.5]) cylinder(d = 13, h = 5.5, $fn = 6);
    translate([0, 0, ear_x[0]]) cylinder(d = 8, h = lever_x[1] - ear_x[0] + 8, $fn = 32);
    translate([0, 0, lever_x[1]]) cylinder(d = 14.4, h = 8, $fn = 6);   // M8 nyloc, 14.4 across corners
  }
}
module hw_link_pin() { hx = lever_x[1] + 0.2 + pin_flange[1];   // M5x40 head seat on the spacer flange
  translate([hx, link_pin_pos[1], link_pin_pos[2]]) rotate([0, 90, 0]) {
    translate([0, 0, -pin_screw_len]) cylinder(d = 5, h = pin_screw_len, $fn = 24);
    cylinder(d = 8.5, h = 5, $fn = 24); } }
module hw_stop_screw() {
  zt = collar_top - collar_h - 1; tip = carriage_z0_up - travel_len;
  translate([stop_contact[0], stop_contact[1], 0]) { translate([0, 0, zt - 5]) cylinder(d = 8.5, h = 5, $fn = 24);  // head sits in the thumbwheel
    translate([0, 0, zt]) cylinder(d = 5, h = tip - zt, $fn = 24); } }
module hw_spring() {   // kickstand spring: lever tail peg to the base post (default holes)
  t = tail_pt(tail_d[tail_default], plunge);
  hull() { translate([ks_x, t[0], t[1]]) sphere(d = ks_od, $fn = 16);
           translate([ks_x, ks_y, ks_anchor_z]) sphere(d = ks_od, $fn = 16); } }
module hw_lock_screw() { translate([0, key_back_y, carriage_z0 + lock_z]) rotate([-90, 0, 0]) {
  cylinder(d = 5, h = carriage_y1 + 1 - key_back_y, $fn = 24);
  translate([0, 0, carriage_y1 + 1 - key_back_y]) cylinder(d = 8.5, h = 5, $fn = 24); } }
module hw_motor() {
  d = tool == "555" ? m555_d : m775_d; len = tool == "555" ? m555_len : m775_len; boss = tool == "555" ? m555_boss : m775_boss;
  fz = kb + f_off(tool_below);
  translate([0, 0, fz]) cylinder(d = d, h = len, $fn = 64);
  translate([0, 0, fz - boss[1]]) cylinder(d = boss[0], h = boss[1] + 0.01, $fn = 48);
}
module hw_chuck_bit() {
  fz = kb + f_off(tool_below); cz = fz - shaft_gap;
  translate([0, 0, cz - 0.01]) cylinder(d = 5, h = shaft_gap - (tool == "555" ? m555_boss[1] : m775_boss[1]) + 0.01, $fn = 24);
  translate([0, 0, cz - chuck_len]) cylinder(d = chuck_d, h = chuck_len, $fn = 48);
  translate([0, 0, cz - chuck_len - bit_stickout]) cylinder(d = 1, h = bit_stickout + 0.01, $fn = 12);
}
module hw_iron_handle() { translate([0, 0, iron_cb - 5]) cylinder(d = iron_d, h = 110, $fn = 64); }
module hw_iron_hot() { translate([0, 0, iron_cb - iron_air_gap - iron_hot_len]) cylinder(d = iron_barrel_d, h = iron_hot_len, $fn = 32); }
module hw_strap_screws() { for (s = [-1, 1]) translate([s * strap_x, -iron_d/2 - 6 - 3, iron_cb + iron_grip_len/2]) rotate([-90, 0, 0]) {
  translate([0, 0, -3]) cylinder(d = 5.5, h = 3, $fn = 24); cylinder(d = 3, h = 25, $fn = 16); } }
