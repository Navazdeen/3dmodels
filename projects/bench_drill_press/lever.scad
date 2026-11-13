// Lever, counterweight lid, depth-stop collar and thumbwheel. Included after params/frame/carriage.

// 2D lever outline in local (u = along lever, + toward the tail; v = up), pivot at origin
module lever_outline() {
  hull() { circle(r = 11, $fn = 64); translate([-lever_r - 7, -lever_web/2]) square([1, lever_web]); }
  hull() { translate([-lever_r - 7, -lever_web/2]) square([1, lever_web]);
           translate([-lever_len, 0]) circle(r = 12, $fn = 48); }   // end supports the handle bar (r != bar radius: no coincident faces)
  translate([8, -9]) square([22, 18]);                // tail carrying the kickstand pegs
}

module lever_local() {
  t = lever_x[1] - lever_x[0];
  difference() {
    union() {
      rotate([90, 0, 90]) linear_extrude(t) lever_outline();
      translate([t - 0.01, -lever_len, 0]) rotate([0, 90, 0]) cylinder(d = 22, h = 60, $fn = 64);  // handle bar
      for (d = tail_d) translate([t - 0.01, d, 0]) rotate([0, 90, 0]) peg();   // kickstand pegs on the outer face, behind the pivot
    }
    translate([-1, 0, 0]) rotate([0, 90, 0]) cylinder(d = pivot_d, h = t + 2, $fn = 48);            // pivot bore
    hull() for (u = [-lever_r + 2, -lever_r - 7 + 1]) translate([-1, u, 0]) rotate([0, 90, 0]) cylinder(d = pin_spacer_od + 0.3, h = t + 2, $fn = 32); // slot rides on the pin spacer
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
    translate([0, 0, thumb_h - 5]) head_pocket(6);                                // M5 socket head, crush-rib press fit
    translate([0, 0, -1]) cylinder(d = knob_key_d, h = thumb_h, $fn = 24);         // 4 mm hex key passes
  }
}

// socket-head pocket: knob_head_d bore with 6 crush ribs biting the knurled head
module head_pocket(h) {
  difference() { cylinder(d = knob_head_d + 0.6, h = h, $fn = 48);
    for (a = [0:60:300]) rotate(a) translate([knob_head_d/2, -0.4, -1]) cube([1, 0.8, h + 2]); }
}

module pin_spacer() {   // the lever slot rides on this; the M5x40 clamps it to the carriage
  translate(link_pin_pos) rotate([0, 90, 0]) difference() {
    union() { cylinder(d = pin_spacer_od, h = lever_x[1] + 0.2 - carriage_x, $fn = 32);
      translate([0, 0, lever_x[1] + 0.2 - carriage_x]) cylinder(d = pin_flange[0], h = pin_flange[1], $fn = 32); }
    translate([0, 0, -1]) cylinder(d = m5_clear, h = 50, $fn = 24);
  }
}
