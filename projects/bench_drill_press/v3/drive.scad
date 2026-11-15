// Drive: pinion shaft, gear pair (main + spring pinion), spring slider, handle, depth-stop ring.
include <BOSL2/std.scad>
include <BOSL2/gears.scad>

module at_shaft(p) { translate([0, pinion_axis[0], pinion_axis[1]]) rotate([shaft_rot(p), 0, 0]) children(); }
module hex_x(af, x0, x1) { translate([x0, 0, 0]) rotate([0, 90, 0]) rotate(30) cylinder(d = af / cos(30), h = x1 - x0, $fn = 6); }

module xcyl(d, x0, x1) { translate([x0, 0, 0]) rotate([0, 90, 0]) cylinder(d = d, h = x1 - x0, $fn = 48); }

// gear cluster: spring pinion (x -18..-6) + spacer + main pinion (-5..5) on the fixed M6; hex socket in the +x face
module gear_cluster() {
  at_shaft(plunge) difference() {
    union() {
      translate([slider_x, 0, 0]) rotate([0, 90, 0]) rotate(spr_phase)
        spur_gear(mod = spr_m, teeth = spr_t, thickness = spr_b, pressure_angle = pa, shaft_diam = 0);
      xcyl(14, slider_x + spr_b/2 - 0.01, -pin_w/2 + 0.01);
      rotate([0, 90, 0]) rotate(gear_phase) spur_gear(mod = pin_m, teeth = pin_t, thickness = pin_w, pressure_angle = pa, shaft_diam = 0);
    }
    xcyl(sleeve_id, slider_x - spr_b/2 - 1, pin_w/2 + 1);                                   // runs on the M6
    hex_x(hex_af + hex_c, pin_w/2 - hex_len - 0.3, pin_w/2 + 1);                                // drive socket
    translate([pin_w/2 + 0.01, 0, 0]) rotate([0, -90, 0]) difference() {                     // bed-face chamfer (+x face)
      cylinder(r = pin_r + pin_m + 1, h = ef + 0.01, $fn = 64);
      translate([0, 0, -0.01]) cylinder(r1 = pin_r + pin_m - ef, r2 = pin_r + pin_m + 0.02, h = ef + 0.03, $fn = 64);
    }
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
      translate([ledge[1] + 0.01, ledge[2], z0 + tab_dz + 5 - 0.01]) rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(ledge[3] - ledge[2])
        scale([-1, 1]) fillet2d(fillet_r);                                                   // fillet on the tab's top root (tension side)
    }
    tear_x(slider_hook_d, slider_x - slider_w/2 - 1, slider_w + 2, spring_y, z0 + 4);  // cross-hole for the spring hook
  }
}

module handle_hub() {   // hub + spokes + round sleeve journals in the +x boss; its hex end drives the cluster. Bolt head holds it on.
  at_shaft(plunge) difference() {
    union() {
      translate([hub_x[0], 0, 0]) rotate([0, 90, 0]) cylinder(d = 26, h = hub_x[1] - hub_x[0], $fn = 64);
      xcyl(sleeve_od, pin_w/2 + 0.2, hub_x[0] + 0.01);                                        // drive sleeve (journal in the +x boss)
      hex_x(hex_af, pin_w/2 - hex_len, pin_w/2 + 0.21);                                       // hex into the cluster's socket
      for (a = [0, 120, 240]) rotate([a, 0, 0]) translate([hub_x[0] + 4, 0, 0]) rotate([0, 90, 0]) linear_extrude(hub_x[1] - hub_x[0] - 4)   // spokes on the bed side
        hull() { circle(d = 16, $fn = 32); translate([-spoke_r, 0]) circle(d = 7, $fn = 24); }   // tapered root
      for (a = [0, 120, 240]) rotate([a, 0, 0]) translate([hub_x[0], 0, spoke_r]) rotate([0, 90, 0]) cylinder(d = 14, h = hub_x[1] - hub_x[0], $fn = 32);
    }
    xcyl(sleeve_id, pin_w/2 - hex_len - 1, hub_x[1] + 1);                                       // on the M6
  }
}


// depth-stop collar on the left rod (prints flat, as used). Slit to the front between two ears, M5 across them;
// the thin back is the hinge. Top face is the stop the head bottom lands on; a 1 mm relief keeps the front gib's
// free end (which reaches the head bottom) off the collar, so the stop load goes into rigid plastic only.
module depth_collar() {
  x = rod_x[0]; zt = collar_z(travel_len); z0 = zt - collar_h; by = rod_y - collar_bolt_dy; zc = z0 + collar_h/2;
  difference() {
    union() {
      translate([x, rod_y, z0]) cylinder(d = collar_d, h = collar_h, $fn = 64);
      translate([x - collar_ear[0]/2, rod_y - collar_ear[1], z0]) cube([collar_ear[0], collar_ear[1], collar_h]);
    }
    translate([x, rod_y, z0 - 1]) cylinder(d = collar_bore, h = collar_h + 2, $fn = 48);
    translate([x, rod_y, 0]) ef_cone(collar_bore, z0);                                    // elephant-foot lead-in
    translate([x - collar_slit/2, rod_y - collar_ear[1] - 1, z0 - 1]) cube([collar_slit, collar_ear[1] + 1, collar_h + 2]);
    tear_x(m5_clear, x - collar_ear[0]/2 - 1, collar_ear[0] + 2, by, zc);                 // M5 x 25 + nut across the slit
    translate([x - gib_b/2 - 1, rod_y - slot_hw[1] - 0.5, zt - 1]) cube([gib_b + 2, slot_hw[1] + 0.5, 2]);   // gib-tip relief, open into the bore (no sliver)
  }
}
