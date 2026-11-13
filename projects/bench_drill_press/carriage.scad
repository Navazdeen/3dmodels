// Carriage and printed sleeves. Included after params.scad and frame.scad.

module dovetail_profile(clear) {   // 2D, x across, y depth from the mouth (y=0) into the part
  w0 = dt_mouth + 2*clear;
  lip = 0.5;                       // straight lip at the mouth: no knife edge
  w1l = w0 + 2*(dt_depth + clear - lip)/tan(dt_angle);
  polygon([[-w0/2, -1], [w0/2, -1], [w0/2, lip], [w1l/2, dt_depth + clear], [-w1l/2, dt_depth + clear], [-w0/2, lip]]);
}

module carriage() {
  z0 = carriage_z0; h = carriage_h;
  difference() {
    union() {
      slab(-carriage_x, carriage_x, carriage_y0, carriage_y1, z0, h, r = 3);
      for (s = [-1, 1]) slab(s > 0 ? 0 : -cear_x, s > 0 ? cear_x : 0, cear_y[0], cear_y[1], z0, h, r = 3);
    }
    for (x = rod_x) {
      translate([x, rod_y, z0 - 1]) cylinder(d = rod_pass, h = h + 2, $fn = 48);
      for (zs = [z0 - 0.01, z0 + h - sleeve_len]) translate([x, rod_y, zs]) cylinder(d = sleeve_pocket, h = sleeve_len + 0.01, $fn = 96);
      // 45° roof over the lower pocket so it prints without support
      translate([x, rod_y, z0 + sleeve_len - 0.01]) cylinder(d1 = sleeve_pocket, d2 = rod_pass - 0.1, h = (sleeve_pocket - rod_pass)/2 * tan(50), $fn = 96);   // 50° from horizontal
      // slit from the sleeve pocket to the outer side, full height
      translate([x > 0 ? x : x - 100, rod_y - clamp_slot/2, z0 - 1]) cube([100, clamp_slot, h + 2]);
      // squeeze screws along y across the slit, one per sleeve
      for (zc = [z0 + sleeve_len/2, z0 + h - sleeve_len/2]) let(sx = sign(x) * squeeze_x)
        translate([sx, 0, zc]) rotate([-90, 0, 0]) {
          translate([0, 0, cear_y[0] - 1]) tear_cyl(m3_insert[0], rod_y - cear_y[0] + 1);
          translate([0, 0, rod_y - 0.1]) tear_cyl(m3_clear, cear_y[1] - rod_y + 1);
          translate([0, 0, cear_y[1] - 3]) tear_cyl(clamp_cb[0], 4);
        }
    }
    // vertical dovetail socket, open top and bottom
    translate([0, carriage_y0, z0 - 1]) linear_extrude(h + 2) dovetail_profile(dt_clear);
    // M5 holder lock: insert at the rear face, screw pushes the key's flat back face
    rear_hole(m5_insert[0], 0, z0 + lock_z, carriage_y1, m5_insert[1]);
    translate([0, carriage_y0 + dt_depth, z0 + lock_z]) rotate([-90, 0, 0]) tear_cyl(m5_clear, carriage_y1 - carriage_y0);
    // M5 link pin insert in the right side face
    tear_x(m5_insert[0], carriage_x - m5_insert[1] - 3, m5_insert[1] + 4, link_pin_pos[1], link_pin_pos[2]);   // +3 run-out for the M5x40 tip
  }
}

module sleeve(bore) {
  difference() {
    cylinder(d = sleeve_od, h = sleeve_len, $fn = 96);
    translate([0, 0, -1]) cylinder(d = bore, h = sleeve_len + 2, $fn = 64);
    for (z = [0, sleeve_len]) translate([0, 0, z]) cylinder(d1 = bore + (z ? -0 : 1), d2 = bore + (z ? 1 : 0), h = 0.5, center = true, $fn = 64);
    for (a = [0, 120, 240]) rotate(a) translate([bore/2 - 0.2, -0.6, -1]) cube([0.7, 1.2, sleeve_len + 2]);  // grease grooves
  }
}

// n notches on the top rim identify the bore in the test set (no font needed)
module sleeve_labelled(bore, n) {
  difference() {
    sleeve(bore);
    for (k = [0:n-1]) rotate(90 + (k - (n-1)/2) * 22) translate([sleeve_od/2 - 0.8, -0.6, sleeve_len - 1.5]) cube([2, 1.2, 2]);
  }
}

module sleeve_at(i) {
  x = rod_x[floor(i / 2)]; zs = i % 2 == 0 ? carriage_z0 : carriage_z0 + carriage_h - sleeve_len;
  translate([x, rod_y, zs]) sleeve(sleeve_bore);
}
