// Head: preloaded V-slide on the rods, rack on the back, 43 mm split ring at the front. Prints upright.

// 2D rack profile in (z, y): teeth along z, tips toward +y; pressure angle pa
module rack2d_z(z0, n) {
  p = PI * pin_m; ha = pin_m; hf = 1.25 * pin_m; bl = 0.1;
  polygon(concat([[z0 - p/2, rack_root_y - 2]],
    [for (i = [0:n-1]) let(c = z0 + i * p) each [
      [c - p/4 - hf * tan(pa) + bl/2, rack_root_y], [c - p/4 + ha * tan(pa) + bl/2, rack_pitch_y + ha],
      [c + p/4 - ha * tan(pa) - bl/2, rack_pitch_y + ha], [c + p/4 + hf * tan(pa) - bl/2, rack_root_y]]],
    [[z0 + (n - 0.5) * p, rack_root_y - 2]]));
}

module head_body() {
  z0 = head_z0;
  slab(-body_x, body_x, body_y0, rack_root_y, z0, head_h, r = 3);
  hull() {                                                          // 43 mm ring blended into the body
    translate([0, 0, z0]) cylinder(d = ring_d + 2 * ring_wall, h = ring_h, $fn = 128);
    translate([-ring_d/2, body_y0, z0]) cube([ring_d, 1, ring_h]);
  }
  for (s = [-1, 1]) translate([s > 0 ? ring_slit/2 : -ring_slit/2 - 8, -(ring_d/2 + ring_wall) - 9, z0]) cube([8, 12, ring_h]);   // clamp ears
  translate([-pin_w/2, 0, 0]) rotate([90, 0, 90]) linear_extrude(pin_w) mirror([1, -1]) rack2d_z(z0 + rack_z0, rack_teeth);   // 2D (z,y) -> world (y,z)
}

module head() {
  z0 = head_z0;
  difference() {
    head_body();
    translate([0, 0, z0 - 1]) cylinder(d = ring_bore, h = ring_h + 2, $fn = 128);
    translate([-ring_slit/2, -(ring_d/2 + ring_wall) - 10, z0 - 1]) cube([ring_slit, 12, ring_h + 2]);   // ring split
    let(y = -(ring_d/2 + ring_wall) - 4.5, z = z0 + ring_h/2) {                               // M5 clamp across the split
      tear_x(m5_insert[0], -ring_slit/2 - 8.5, 8.5, y, z);
      tear_x(m5_clear, 0, ring_slit/2 + 8.5, y, z);
    }
    for (x = rod_x) translate([x - slot_hw[0], rod_y - slot_hw[1], z0 - 1]) cube([2 * slot_hw[0], 2 * slot_hw[1], head_h + 2]);
    // thread-forming M3 adjusters (pilot 2.6) behind each gib, through the slot wall
    for (x = rod_x, k = [0, 1]) let(s = -seat_side[k], zc = z0 + seat_z[k])
      translate([x, rod_y + s * slot_hw[1] - (s > 0 ? 0 : 6), zc]) rotate([-90, 0, 0]) cylinder(d = 2.6, h = 6 + 0.01, $fn = 16);
  }
  for (x = rod_x, k = [0, 1]) {
    s = seat_side[k]; zc = z0 + seat_z[k]; zz = [k == 0 ? z0 : zc - seat_h/2, zc + seat_h/2];   // bottom seats start on the bed
    // rigid seat on side s: V on the left rod, flat pad on the right rod
    difference() {
      translate([x - slot_hw[0], s > 0 ? rod_y : rod_y - slot_hw[1], zz[0]]) cube([2 * slot_hw[0], slot_hw[1], seat_h]);
      translate([x, rod_y, zz[0] - 1]) linear_extrude(zz[1] - zz[0] + 2)
        if (x < 0) rotate(45) square(rod_d, center = true);                    // 90° V tangent to the rod
        else translate([-slot_hw[0] - 1, s > 0 ? -50 : -rod_d/2 + 0.001 - 50 + 50]) square([2 * slot_hw[0] + 2, 0.01]);
      if (x > 0) translate([x - slot_hw[0] - 1, s > 0 ? rod_y - 50 : rod_y - rod_d/2, zz[0] - 1])
        cube([2 * slot_hw[0] + 2, s > 0 ? 50 + rod_d/2 : 50, zz[1] - zz[0] + 2]);      // flat pad face tangent to the rod
    }
    gib(x, -s, k == 0 ? z0 : zc - seat_h/2 - (gib_L - seat_h/2) + seat_h, k);
  }
}

// flexure gib on side g (+1 behind the rod) of rod x; blade from root to the contact zone, bump presses the rod
module gib(x, g, _unused, k) {
  z0 = head_z0; zc = z0 + seat_z[k];
  blade = [rod_y + g * (rod_d/2 + 2 - gib_gap), rod_y + g * (rod_d/2 + 2 - gib_gap + gib_t)];    // y faces of the blade
  bump  = [rod_y + g * (rod_d/2 - gib_gap), blade[0] + g * 0.01];   // 0.01 into the blade: never face-to-face
  zr = k == 0 ? [z0, z0 + seat_z[0] + gib_L] : [zc - gib_L, z0 + head_h];   // bottom gib stands on the bed, top gib grows from its root
  root = k == 0 ? [zr[1] - 5, zr[1]] : [zr[0], zr[0] + 5];
  translate([x - gib_b/2, min(blade), zr[0]]) cube([gib_b, gib_t, zr[1] - zr[0]]);
  translate([x - gib_b/2, min(bump), zc - seat_h/2]) cube([gib_b, abs(bump[1] - bump[0]), seat_h]);
  translate([x - slot_hw[0] - 0.01, min(blade[1], rod_y + g * slot_hw[1]), root[0]])               // root block to the slot wall
    cube([2 * slot_hw[0] + 0.02, abs(rod_y + g * slot_hw[1] - blade[1]) + 0.01, 5]);
}
