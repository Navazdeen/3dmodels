// Drive: pinion shaft, gear pair (main + spring pinion), spring slider, handle, depth-stop ring.
include <BOSL2/std.scad>
include <BOSL2/gears.scad>

module at_shaft(p) { translate([0, pinion_axis[0], pinion_axis[1]]) rotate([shaft_rot(p), 0, 0]) children(); }
module hex_x(af, x0, x1) { translate([x0, 0, 0]) rotate([0, 90, 0]) rotate(30) cylinder(d = af / cos(30), h = x1 - x0, $fn = 6); }

module xcyl(d, x0, x1) { translate([x0, 0, 0]) rotate([0, 90, 0]) cylinder(d = d, h = x1 - x0, $fn = 48); }
// shaft goes in from -x: every section +x of the collar passes the -x bore; +x of the main pinion passes its hex
module shaft() {
  c0 = col[0] - collar[1]; cone = (collar[0] - shaft_d) / 2; sp = [slider_x - spr_b/2, slider_x + spr_b/2];
  at_shaft(plunge) {
    xcyl(shaft_d, shaft_x[0], c0 - cone + 0.01);                                                  // stop section
    translate([c0 - cone, 0, 0]) rotate([0, 90, 0]) cylinder(d1 = shaft_d, d2 = collar[0], h = cone + 0.01, $fn = 48);  // 45° under the collar
    xcyl(collar[0], c0, col[0]);                                                                   // collar (bears on the -x wall)
    xcyl(shaft_d, col[0], sp[0] + 0.01);                                                           // -x journal + spacer
    translate([slider_x, 0, 0]) rotate([0, 90, 0]) rotate(spr_phase)
      spur_gear(mod = spr_m, teeth = spr_t, thickness = spr_b, pressure_angle = pa, shaft_diam = 0);   // spring pinion (core Ø9.5)
    xcyl(shaft_d, sp[1] - 0.01, -pin_w/2 - 0.5);                                                   // spacer up to the main pinion
    hex_x(shaft_hex, -pin_w/2 - 0.5 - 0.01, pin_w/2 + 0.5);                                         // main pinion seat
    xcyl(journal_px, pin_w/2 + 0.5 - 0.01, hub_x[0] - 0.5);                                         // +x journal Ø9.7
    hex_x(hub_hex, hub_x[0] - 0.6, hub_x[1]);                                                       // handle seat
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
      translate([ledge[0], ledge[2], z0 + tab_dz]) cube([ledge[1] - ledge[0] + 1, ledge[3] - ledge[2], 5]);   // tab (1 mm into the body): rests on the ledge = top stop
    }
    tear_x(slider_hook_d, slider_x - slider_w/2 - 1, slider_w + 2, spring_y, z0 + 4);  // cross-hole for the spring hook
  }
}

module handle_hub() {   // flat on the bed; its sleeve bears on the +x wall (holds the shaft against pulling out -x)
  at_shaft(plunge) difference() {
    union() {
      translate([hub_x[0], 0, 0]) rotate([0, 90, 0]) cylinder(d = 26, h = hub_x[1] - hub_x[0], $fn = 64);
      xcyl(journal_px + 5, col[1], hub_x[0] + 0.01);                                              // sleeve to the +x wall
      for (a = [0, 120, 240]) rotate([a, 0, 0]) translate([hub_x[0] + 4, 0, 0]) rotate([0, 90, 0]) linear_extrude(hub_x[1] - hub_x[0] - 4)   // spokes on the bed side
        hull() { circle(d = 9, $fn = 24); translate([-spoke_r, 0]) circle(d = 7, $fn = 24); }
      for (a = [0, 120, 240]) rotate([a, 0, 0]) translate([hub_x[0], 0, spoke_r]) rotate([0, 90, 0]) cylinder(d = 14, h = hub_x[1] - hub_x[0], $fn = 32);
    }
    hex_x(hub_hex + 0.15, hub_x[0] - 0.01, hub_x[1] + 1);                                        // press fit on the hex
    xcyl(journal_px + 0.15, col[1] - 1, hub_x[0] + 0.02);                                         // sleeve bore
  }
}

// tooth angle at full plunge: just touching the pin (approaching as the head drops)
R_lug = norm(lug_off);
stop_tang = asin((2.5 + lug_pin_d/2) / R_lug);
stop_contact_deg = atan2(lug_off[0], lug_off[1]) + stop_tang;
split_deg = (tick_dir * (stop_tang + travel_len / pin_r * 180 / PI) + 360) / 2 - 180;   // rotate the -z split to the middle of the unused arc (tooth at 0, ticks 22..240°)
function tick_angle(i) = tick_dir * (stop_tang + i / pin_r * 180 / PI);   // tick i sits on the pin at the top when the stop is set to i mm
module stop_ring() {
  w = stop_x[1] - stop_x[0];
  at_shaft(plunge) rotate([-shaft_rot(travel_len) - stop_contact_deg, 0, 0]) difference() {
    union() {
      xcyl(2 * stop_ring_r, stop_x[0], stop_x[1]);
      translate([stop_x[0], -2.5, 0]) cube([w, 5, stop_tooth_r]);                                // stop tooth
    }
    for (i = [0:2:40]) rotate([tick_angle(i), 0, 0])                                             // 2 mm ticks, long every 10
      translate([stop_x[0] - 0.01, -0.3, stop_ring_r - 0.6]) cube([i % 10 == 0 ? 5 : 2.5, 0.6, 1]);
    xcyl(shaft_d + 0.15, stop_x[0] - 1, stop_x[1] + 1);
    rotate([split_deg, 0, 0]) {                                                                 // split + clamps on the arc the scale doesn't use
    translate([stop_x[0] - 1, -0.75, -stop_ring_r - 1]) cube([w + 2, 1.5, stop_ring_r - shaft_d/2 + 1.1]);   // clamp split
    let(zc = -(shaft_d/2 + stop_ring_r)/2, ch = sqrt(stop_ring_r^2 - zc^2))                         // 2 tangential M3 clamps
      for (xc = [stop_x[0] + w/4, stop_x[1] - w/4]) translate([xc, 0, zc]) rotate([-90, 0, 0]) {
        translate([0, 0, -ch - 1]) cylinder(d = 6, h = ch - 2.5 + 1, $fn = 24);
        translate([0, 0, -3]) cylinder(d = m3_clear, h = 3.1, $fn = 16);
        translate([0, 0, -0.1]) cylinder(d = 2.6, h = ch + 1.1, $fn = 16);
      }
    }
  }
}
