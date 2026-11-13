// Frame parts: base, top bridge, spine. Included (not used) so -D variant reaches them.

// rounded-rect slab with chamfered top & bottom edges.
// Accepted validator WARN: the 1 mm bottom chamfer at rounded corners reads as ~23 mm2 overhang
// at z=0 above the bed (first 1 mm only; prints fine, acts as elephant-foot relief).
module slab(x0, x1, y0, y1, z0, h, r=corner_r, c=edge_ch) {
  hull() for (k = [[c, 0], [0, c], [h - c, 0], [h, c]]) if (k[0] <= h)
    translate([0, 0, z0 + min(k[0], h) - (k[0]==h||k[0]==h-c ? 0.01 : 0)])
      linear_extrude(0.01) offset(r = r - k[1]) offset(delta = -r)
        translate([x0, y0]) square([x1 - x0, y1 - y0]);
}

// horizontal hole printable without support: teardrop with its point toward world +z
// (call inside rotate([-90,0,0]), where local -y maps to world +z)
module tear_cyl(d, h) {
  linear_extrude(h) hull() { circle(d = d, $fn = 32);           // walls 40° from vertical: tip at r/sin(40)
    translate([0, -d/2 / sin(40)]) square(0.01, center = true); }
}

// split clamp for one rod at x=rx: slot in plane y=rod_y from rod to the outer side edge,
// M3 screw along y from the rear face across the slot into an insert in front.
module rod_clamp_cut(rx, z0, h, rear_y) {
  s = sign(rx);
  edge = s > 0 ? 200 : -200;
  translate([min(rx, edge), rod_y - clamp_slot/2, z0 - 1]) cube([abs(edge - rx), clamp_slot, h + 2]);
  sx = rx + s * (rod_d/2 + clamp_screw_dx - rod_d/2 + 2);  // outboard of the rod
  translate([sx, 0, z0 + h/2]) rotate([-90, 0, 0]) {
    translate([0, 0, rod_y - 12]) tear_cyl(m3_insert[0], 12.1);        // insert, front jaw
    translate([0, 0, rod_y - 0.1]) tear_cyl(m3_clear, rear_y - rod_y + 1);
    translate([0, 0, rear_y - clamp_cb[1]]) tear_cyl(clamp_cb[0], clamp_cb[1] + 1);
  }
}

module base() {
  difference() {
    slab(-base_w/2, base_w/2, base_y0, base_y1, -base_t, base_t);
    for (x = rod_x) {
      translate([x, rod_y, -rod_socket_depth]) cylinder(d = rod_bore, h = rod_socket_depth + 1, $fn=64);
      translate([x, rod_y, -0.6]) cylinder(d1 = rod_bore, d2 = rod_bore + 1.2, h = 0.61, $fn=64);  // lead-in
      rod_clamp_cut(x, -base_t, base_t, base_y1);
    }
    translate([-pad[0]/2, -pad[1]/2, -pad[2]]) cube([pad[0], pad[1], pad[2] + 1]);          // work pad
    for (x = spine_insert_x) translate([x, (spine_y[0] + spine_y[1])/2, -m3_insert[1]])
      cylinder(d = m3_insert[0], h = m3_insert[1] + 1, $fn=32);
    for (x = [-1, 1] * (base_w/2 - 12), y = [base_y0 + 12, base_y1 - 30])                   // bench screws
      translate([x, y, -base_t - 1]) { cylinder(d = bench_hole, h = base_t + 2, $fn=32);
        translate([0, 0, base_t + 1 - 4]) cylinder(d = 8.5, h = 5, $fn=32); }
  }
}
