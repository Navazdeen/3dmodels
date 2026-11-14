// Bought-part reference solids (hw_). Not printed.
module hw_rods() { for (x = rod_x) translate([x, rod_y, -rod_socket]) cylinder(d = rod_d, h = rod_len, $fn = 48); }
