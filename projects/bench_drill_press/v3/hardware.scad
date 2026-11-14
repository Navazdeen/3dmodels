// Bought-part reference solids (hw_). Not printed.
module hw_rods() { for (x = rod_x) translate([x, rod_y, -rod_socket]) cylinder(d = rod_d, h = rod_len, $fn = 48); }
module hw_spring() { z1 = slider_z0_up + slider_dz(plunge) + 3;
  translate([slider_x, spring_y, ks_anchor_z]) cylinder(d = ks_od, h = z1 - ks_anchor_z, $fn = 24); }
