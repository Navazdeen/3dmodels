// Reference solids for bought parts (hw_). Not printed.
module hw_rods() { for (x = rod_x) translate([x, rod_y, -rod_socket_depth]) cylinder(d=rod_d, h=rod_len, $fn=48); }
module hw_pivot() {   // M8 bolt along +x: head left of the ear, nyloc right of the lever
  translate([0, pivot_pos[1], pivot_pos[2]]) rotate([0, 90, 0]) {
    translate([0, 0, ear_x[0] - 5.5]) cylinder(d = 13, h = 5.5, $fn = 6);
    translate([0, 0, ear_x[0]]) cylinder(d = 8, h = lever_x[1] - ear_x[0] + 8, $fn = 32);
    translate([0, 0, lever_x[1]]) cylinder(d = 15, h = 8, $fn = 6);
  }
}
module hw_link_pin() { translate(link_pin_pos) rotate([0, 90, 0]) translate([0, 0, -m5_insert[1]]) {
  cylinder(d = 5, h = lever_x[1] - carriage_x + m5_insert[1], $fn = 24);
  translate([0, 0, lever_x[1] - carriage_x + m5_insert[1]]) cylinder(d = 8.5, h = 5, $fn = 24); } }
module hw_stop_screw() {
  zt = collar_top - collar_h - 1; tip = carriage_z0_up - travel_len;
  translate([stop_contact[0], stop_contact[1], 0]) { translate([0, 0, zt - 5]) cylinder(d = 8.5, h = 5, $fn = 24);  // head sits in the thumbwheel
    translate([0, 0, zt]) cylinder(d = 5, h = tip - zt, $fn = 24); } }
module hw_spring() {
  a = lever_pt(spring_d[spring_default], plunge); top = [pivot_pos[1] - spring_d[spring_default], spring_tab_z];
  hull() { translate([spring_x, a[0], a[1]]) sphere(d = spring_wire_od, $fn = 16);
           translate([spring_x, top[0], top[1]]) sphere(d = spring_wire_od, $fn = 16); } }
