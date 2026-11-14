// Drive: pinion shaft, gear pair (main + spring pinion), spring slider, handle, depth-stop ring.
include <BOSL2/std.scad>
include <BOSL2/gears.scad>

module at_shaft(p) { translate([0, pinion_axis[0], pinion_axis[1]]) rotate([shaft_rot(p), 0, 0]) children(); }
module hex_x(af, x0, x1) { translate([x0, 0, 0]) rotate([0, 90, 0]) rotate(30) cylinder(d = af / cos(30), h = x1 - x0, $fn = 6); }

module shaft() {
  at_shaft(plunge) {
    hex_x(shaft_hex, -pin_w/2 - 1, pin_w/2 + 0.5);                                               // main pinion seat
    for (x = [[shaft_x[0], -pin_w/2 - 1 + 0.01], [pin_w/2 + 0.5 - 0.01, slider_x - spr_b/2 + 0.01], [slider_x + spr_b/2 - 0.01, hub_x[0] - 0.5]])
      translate([x[0], 0, 0]) rotate([0, 90, 0]) cylinder(d = shaft_d, h = x[1] - x[0], $fn = 48);   // journals, stop section, spacers
    translate([slider_x, 0, 0]) rotate([0, 90, 0]) rotate(spr_phase)                               // spring pinion cut into the shaft
      spur_gear(mod = spr_m, teeth = spr_t, thickness = spr_b, pressure_angle = pa, shaft_diam = 0);
    translate([col[1], 0, 0]) rotate([0, 90, 0]) cylinder(d = collar[0], h = collar[1], $fn = 48);  // retaining collar
    translate([col[1] + collar[1] - 0.01, 0, 0]) rotate([0, 90, 0]) cylinder(d1 = collar[0], d2 = shaft_d - 0.5, h = (collar[0] - shaft_d)/2 + 0.25, $fn = 48);  // 45° above the collar (prints upright)
    hex_x(shaft_hex, hub_x[0] - 0.6, hub_x[1]);                                                     // handle seat
  }
}

module gear_pair() {   // main pinion on the hex
  at_shaft(plunge) difference() {
    rotate([0, 90, 0]) rotate(gear_phase) spur_gear(mod = pin_m, teeth = pin_t, thickness = pin_w, pressure_angle = pa, shaft_diam = 0);
    hex_x(shaft_hex + 0.25, -pin_w/2 - 1, pin_w/2 + 1);
  }
}

// rack along z with tips toward dir (+1: +y, -1: -y); pitch line at pitch_y
module rack_z(x0, w, z0, n, m, pitch_y, dir, back) {
  p = PI * m; ha = m; hf = 1.25 * m; bl = 0.1; root = pitch_y - dir * hf;
  translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(w) mirror([1, -1])
    polygon(concat([[z0 - p/2, root - dir * back]],
      [for (i = [0:n-1]) let(c = z0 + i * p) each [
        [c - p/4 - hf * tan(pa) + bl/2, root], [c - p/4 + ha * tan(pa) + bl/2, pitch_y + dir * ha],
        [c + p/4 - ha * tan(pa) - bl/2, pitch_y + dir * ha], [c + p/4 + hf * tan(pa) - bl/2, root]]],
      [[z0 + (n - 0.5) * p, root - dir * back]]));
}

module spring_slider() {
  z0 = slider_z0_up + slider_dz(plunge); rt = pinion_axis[0] + spr_r + 1.25 * spr_m;   // rack root (front face)
  difference() {
    union() {
      translate([slider_x - slider_w/2, rt, z0]) cube([slider_w, slider_back - rt, slider_h]);
      rack_z(slider_x - spr_b/2 + 1, spr_b - 2, z0 + 2, floor((slider_h - 4) / (PI * spr_m)), spr_m, pinion_axis[0] + spr_r, -1, 0.01);
      translate([ledge[0] - 0.01, ledge[2], z0]) cube([ledge[1] - ledge[0], ledge[3] - ledge[2], 5]);   // tab: rests on the ledge = top stop
    }
    translate([slider_x - 3.5, spring_y - 3, z0 - 1]) cube([7, 6, 6]);                 // hook pocket, bar above it
  }
}

module handle_hub() {   // flat on the bed: hub, spokes and grips all span hub_x
  at_shaft(plunge) difference() {
    union() {
      translate([hub_x[0], 0, 0]) rotate([0, 90, 0]) cylinder(d = 26, h = hub_x[1] - hub_x[0], $fn = 64);
      for (a = [0, 120, 240]) rotate([a, 0, 0]) translate([hub_x[0] + 4, 0, 0]) rotate([0, 90, 0]) linear_extrude(hub_x[1] - hub_x[0] - 4)   // spokes on the bed side
        hull() { circle(d = 9, $fn = 24); translate([-spoke_r, 0]) circle(d = 7, $fn = 24); }
      for (a = [0, 120, 240]) rotate([a, 0, 0]) translate([hub_x[0], 0, spoke_r]) rotate([0, 90, 0]) cylinder(d = 14, h = hub_x[1] - hub_x[0], $fn = 32);
    }
    hex_x(shaft_hex + 0.15, hub_x[0] - 1, hub_x[1] + 1);                              // press fit on the hex
  }
}

// tooth angle at full plunge: just touching the lug's +y face (approaching as the head drops)
R_lug = norm(lug_off);
stop_contact_deg = atan2(lug_off[0], lug_off[1]) + asin((2.5 + lug_pin_d/2) / R_lug);   // pin bearing angle + tangency
module stop_ring() {
  at_shaft(plunge) rotate([-shaft_rot(travel_len) - stop_contact_deg, 0, 0]) difference() {
    union() {
      translate([stop_x[0], 0, 0]) rotate([0, 90, 0]) cylinder(r = stop_ring_r, h = stop_x[1] - stop_x[0], $fn = 64);
      translate([stop_x[0], -2.5, 0]) cube([stop_x[1] - stop_x[0], 5, stop_tooth_r]);            // stop tooth
      translate([stop_x[1] - 0.01, 0, 0]) rotate([0, 90, 0]) cylinder(r = shaft_d/2 + 1.5, h = col[0] - stop_x[1] + 0.01, $fn = 48);  // sleeve to the -x wall: axial retention
    }
    for (i = [0:2:40]) let(ang = -i * 180 / PI / pin_r) if (abs(abs(ang) - 180) > 10) rotate([ang, 0, 0])   // scale: 2 mm ticks, 10 mm long; skip the clamp split
      translate([stop_x[0] - 0.01, -0.3, stop_ring_r - 0.6]) cube([i % 10 == 0 ? 4 : 2, 0.6, 1]);
    translate([stop_x[0] - 1, 0, 0]) rotate([0, 90, 0]) cylinder(d = shaft_d + 0.15, h = col[0] - stop_x[0] + 2, $fn = 48);   // bore through ring + sleeve
    translate([stop_x[0] - 1, -0.75, -stop_ring_r - 1]) cube([stop_x[1] - stop_x[0] + 2, 1.5, stop_ring_r - shaft_d/2 + 1.1]);   // clamp split
    let(zc = -(shaft_d/2 + stop_ring_r)/2, xc = (stop_x[0] + stop_x[1])/2, ch = sqrt(stop_ring_r^2 - zc^2))   // tangential M3 clamp across the split
      translate([xc, 0, zc]) rotate([-90, 0, 0]) {
        translate([0, 0, -ch - 1]) cylinder(d = 6, h = ch - 2.5 + 1, $fn = 24);          // head counterbore (-y side)
        translate([0, 0, -3]) cylinder(d = m3_clear, h = 3.1, $fn = 16);                 // clearance up to the split
        translate([0, 0, -0.1]) cylinder(d = 2.6, h = ch + 1.1, $fn = 16);               // thread-forming pilot, open on +y
      }
  }
}
