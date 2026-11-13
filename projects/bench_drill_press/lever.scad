// Lever, counterweight lid, depth-stop collar and thumbwheel. Included after params/frame/carriage.

// 2D lever outline in local (u = along lever, + toward the tail; v = up), pivot at origin
module lever_outline() {
  hull() { circle(r = 11, $fn = 64); translate([-lever_r - 7, -lever_web/2]) square([1, lever_web]); }
  hull() { translate([-lever_r - 7, -lever_web/2]) square([1, lever_web]);
           translate([-lever_len, 0]) circle(r = 12, $fn = 48); }   // end supports the handle bar (r != bar radius: no coincident faces)
  translate([8, -10]) square([32, 20]);               // tail (counterweight block)
}

module lever_local() {
  t = lever_x[1] - lever_x[0];
  difference() {
    union() {
      rotate([90, 0, 90]) linear_extrude(t) lever_outline();
      translate([0, 8, -10]) cube([20, 32, 20]);                                  // tail widened outward (+x)
      translate([t - 0.01, -lever_len, 0]) rotate([0, 90, 0]) cylinder(d = 22, h = 60, $fn = 64);  // handle bar
      for (d = spring_d) translate([t - 0.01, -d, 0]) rotate([0, 90, 0]) peg();
    }
    translate([-1, 0, 0]) rotate([0, 90, 0]) cylinder(d = pivot_d, h = t + 2, $fn = 48);            // pivot bore
    hull() for (u = [-lever_r + 2, -lever_r - 7 + 1]) translate([-1, u, 0]) rotate([0, 90, 0]) cylinder(d = m5_clear, h = t + 2, $fn = 32); // pin slot
    translate([20 - cw_pocket[0], 8 + 4, -cw_pocket[2]/2]) cube([cw_pocket[0] + 1, cw_pocket[1], cw_pocket[2]]); // counterweight pocket, opens on the outer (+x) face
  }
}

module peg() {   // printed spring peg along +z from its base, with a retaining lip
  cylinder(d = peg_d, h = peg_len, $fn = 32);
  translate([0, 0, peg_len - 1.8]) cylinder(d1 = peg_d, d2 = peg_d + 1.6, h = 0.8, $fn = 32);   // 45° lip, no knife edge
  translate([0, 0, peg_len - 1.0]) cylinder(d = peg_d + 1.6, h = 1.0, $fn = 32);
}

module lever() {
  translate([lever_x[0], pivot_pos[1], pivot_pos[2]]) rotate([-lever_angle(plunge), 0, 0]) lever_local();
}

module cw_lid() {   // press-fit plug + flange closing the counterweight pocket from the +x side
  translate([lever_x[0], pivot_pos[1], pivot_pos[2]]) rotate([-lever_angle(plunge), 0, 0])
    translate([20, 12, 0]) {
      translate([-3, 0.15, -cw_pocket[2]/2 + 0.15]) cube([3, cw_pocket[1] - 0.3, cw_pocket[2] - 0.3]);
      translate([0, -1.5, -cw_pocket[2]/2 - 1.5]) cube([2, cw_pocket[1] + 3, cw_pocket[2] + 3]); }
}

module collar() {
  zc = collar_top - collar_h; rc = [rod_x[0], rod_y]; sp = [stop_contact[0], stop_contact[1]];
  difference() {
    translate([0, 0, zc]) linear_extrude(collar_h) hull() { translate(rc) circle(d = collar_od, $fn = 64); translate(rc + [0, 7]) square([20, 8], center = true); translate(sp) circle(r = 7, $fn = 48); }
    translate([rc[0], rc[1], zc - 1]) cylinder(d = rod_bore, h = collar_h + 2, $fn = 64);
    translate([rc[0] - clamp_slot/2, rc[1], zc - 1]) cube([clamp_slot, 20, collar_h + 2]);              // rear slit
    // M3 squeeze screw across the slit (along x), teardrop holes
    tear_x(clamp_cb[0], rc[0] - 15, 6, rc[1] + 7, zc + collar_h/2);
    tear_x(m3_clear, rc[0] - 10, 10.1, rc[1] + 7, zc + collar_h/2);
    tear_x(m3_insert[0], rc[0], m3_insert[1] + 1, rc[1] + 7, zc + collar_h/2);
    translate([sp[0], sp[1], zc - 1]) cylinder(d = m5_insert[0], h = collar_h + 2, $fn = 32);           // M5 insert (from below)
  }
}

module thumbwheel() {
  zt = collar_top - collar_h - 1 - thumb_h;     // 1 mm below the collar at the default setting
  translate([stop_contact[0], stop_contact[1], zt]) difference() {
    cylinder(d = thumb_d, h = thumb_h, $fn = 24);                                  // 24 flats = grip
    translate([0, 0, thumb_h - 5]) cylinder(d = 8.7, h = 6, $fn = 32);              // M5 socket head pocket (press fit)
    translate([0, 0, -1]) cylinder(d = 3, h = thumb_h, $fn = 16);                  // hex-key access
  }
}
