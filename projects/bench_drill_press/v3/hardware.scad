// Bought-part reference solids (hw_). Not printed.
module hw_rods() { for (x = rod_x) translate([x, rod_y, -rod_socket]) cylinder(d = rod_d, h = rod_len, $fn = 48); }
module hw_spring() { z1 = slider_z0_up + slider_dz(plunge) + 4 - slider_hook_d/2;
  translate([slider_x, spring_y, ks_anchor_z]) cylinder(d = ks_od, h = z1 - ks_anchor_z, $fn = 24); }
function tool_face_z() = head_z0 - tool_s;              // motor face / iron datum (tip + tool_D)
module hw_motor() {
  d = tool == "555" ? m555_d : m775_d; len = tool == "555" ? m555_len : m775_len; boss = tool == "555" ? m555_boss : m775_boss;
  translate([0, 0, tool_face_z()]) cylinder(d = d, h = len, $fn = 64);
  translate([0, 0, tool_face_z() - boss[1]]) cylinder(d = boss[0], h = boss[1] + 0.01, $fn = 48);
}
module hw_chuck_bit() { cz = tool_face_z() - shaft_gap;
  translate([0, 0, cz - 0.01]) cylinder(d = 5, h = shaft_gap - (tool == "555" ? m555_boss[1] : m775_boss[1]) + 0.01, $fn = 24);
  translate([0, 0, cz - chuck_len]) cylinder(d = chuck_d, h = chuck_len, $fn = 48);
  translate([0, 0, cz - chuck_len - bit_stickout]) cylinder(d = 1, h = bit_stickout + 0.01, $fn = 12); }
module hw_iron_handle() { translate([0, 0, tool_face_z() - iron_air_gap]) cylinder(d = iron_d, h = 120, $fn = 64); }   // handle starts just above the hot zone
module hw_iron_hot() { translate([0, 0, tool_face_z() - tool_D]) cylinder(d = iron_barrel_d, h = iron_hot_len, $fn = 32); }
