// Reference solids for bought parts (hw_). Not printed.
module hw_rods() { for (x = rod_x) translate([x, rod_y, -rod_socket_depth]) cylinder(d=rod_d, h=rod_len, $fn=48); }
