// One-piece C-frame: base + hollow column + top arms. Prints as modelled (base on the bed).

module slab(x0, x1, y0, y1, z0, h, r = 6, c = 1) {
  module rr(o) offset(r = r + o) offset(delta = -r) translate([x0, y0]) square([x1 - x0, y1 - y0]);
  hull() { translate([0, 0, z0]) linear_extrude(h) rr(-c); translate([0, 0, z0 + c]) linear_extrude(h - 2*c) rr(0); }
}
// hole along +x from x0, length l, centre (y,z); teardrop tip up (support-free)
module tear_x(d, x0, l, y, z) {
  translate([x0, y, z]) rotate([0, 90, 0]) linear_extrude(l) hull() { circle(d = d, $fn = 48);
    translate([-d/2 / sin(40), 0]) square(0.01, center = true); }
}

// hole along +x with the teardrop tip toward world direction (ty, tz) — set per part to its print "up"
module tear_xd(d, x0, l, y, z, ty = 0, tz = 1) {
  translate([x0, y, z]) rotate([0, 90, 0]) linear_extrude(l) hull() { circle(d = d, $fn = 48);
    translate([-tz, ty] * (d/2 / sin(40))) square(0.01, center = true); }
}
module tear_y(d, x, y0, l, z, flip = false) {   // hole along +y, tip toward +z (or -z)
  translate([x, y0, z]) rotate([-90, 0, 0]) linear_extrude(l) hull() { circle(d = d, $fn = 48);
    translate([0, (flip ? 1 : -1) * d/2 / sin(40)]) square(0.01, center = true); }
}

// concave fillet profile: fills the corner at the origin between the +u and +v legs
module fillet2d(r) { difference() { square(r); translate([r, r]) circle(r = r, $fn = 24); } }
// bed-side lead-in: a cone (d+2*ef -> d over ef) cut at a hole entry on the bed face
module ef_cone(d, z0, up = true) { translate([0, 0, up ? z0 - 0.01 : z0 - ef + 0.01]) cylinder(d1 = up ? d + 2*ef : d, d2 = up ? d : d + 2*ef, h = ef, $fn = 64); }

module column_block(z0, z1) { translate([col[0], col[2], z0]) cube([col[1] - col[0], col[3] - col[2], z1 - z0]); }

// footprint the column + cover occupy (outer), and the pocket/collar inner outline
module col_outline(c = 0) { translate([col[0] - c, col[2] - c]) square([col[1] - col[0] + 2*c, col[3] + cover_t - col[2] + 2*c]); }
// M5 clamp holes through a collar/skirt and the column's side walls (along x) and through the rear wall + cover (along y)
// up = the part's print-up direction as world (y, z): base [0,1], column [1,0], arm [0,-1]
module joint_bolts(zc, up = [0, 1], ys = bolt_y) {   // M5s per side wall, along x through the collar/skirt and the column wall
  for (y = ys) tear_xd(5.5, col[0] - cjoint[0] - 1, col[1] - col[0] + 2 * cjoint[0] + 2, y, zc, up[0], up[1]);
}

// captive nut pockets inside the column top (the arm joint is closed in by the cover before its screws go in).
// One block per wall rising from the front wall (no ledge face-down); flats face +-y so each pocket roof is a 4.7 mm bridge.
module nut_block(zc, cut = false) {
  hz = nut_pocket[0] / cos(30) / 2 + 1.6;
  for (s = [-1, 1]) let(xw = s * (col[1] - wall), xi = xw - s * nut_pocket[1])
    if (!cut) translate([min(xw, xi) - (s > 0 ? 0 : 0.01), col[2] + wall - 0.01, zc - hz]) cube([nut_pocket[1] + 0.01, nut_block_y1 - col[2] - wall, 2 * hz]);
    else for (y = top_bolt_y) translate([min(xw, xi) - 0.01, y, zc]) rotate([0, 90, 0]) cylinder(d = nut_pocket[0] / cos(30), h = nut_pocket[1] + 0.02, $fn = 6);
}

module base() {
  difference() {
    union() {
      slab(-base_x, base_x, base_y[0], base_y[1], -base_t, base_t);
      translate([0, 0, -0.01]) linear_extrude(cjoint[1] + 0.01) col_outline(key_c + cjoint[0]);   // collar block (pocket cut through it)
    }
    translate([0, 0, -key_d]) linear_extrude(key_d + cjoint[1] + 1) col_outline(key_c);  // column pocket, one cut through collar + base
    joint_bolts(cjoint[1] / 2);
    for (x = rod_x) {
      translate([x, rod_y, -rod_socket]) cylinder(d = rod_bore, h = rod_socket + 0.01, $fn = 64);
      translate([x, rod_y, -0.6]) cylinder(d1 = rod_bore, d2 = rod_bore + 1.2, h = 0.61, $fn = 64);
    }
    translate([-pad[0]/2, -pad[1]/2, -pad[2]]) cube([pad[0], pad[1], pad[2] + 1]);      // work-pad pocket
  }
  difference() {                                                                          // spring anchor post on the pocket floor
    translate([slider_x - 4, spring_y - 4, -key_d - 0.01]) cube([8, 8, ks_anchor_z + 6 + key_d]);
    tear_x(4, slider_x - 5, 10, spring_y, ks_anchor_z);                                  // hook hole
  }
}

module column() {   // U-channel, printed front face down (+y up)
  z0 = -key_d; z1 = col_top + key_d;
  difference() {
    union() {
      difference() {
        column_block(z0, z1);
        translate([col[0] + wall, col[2] + wall, z0 - 1]) cube([col[1] - col[0] - 2*wall, col[3] - col[2], z1 - z0 + 2]);   // open back
      }
      // bearing bosses reach inward to boss_len; each blends into the front wall at 45° (no overhang face-down)
      intersection() {
        for (bx = [[col[0] + wall - 0.01, col[0] + boss_len], [col[1] - boss_len, col[1] - wall + 0.01]])
          let(r = (bx[0] < 0 ? shaft_bore : bore_px)/2 / sin(40) + 1.6, dy = pinion_axis[0] - col[2] - wall)   // covers the teardrop tip
          hull() {
            translate([bx[0], pinion_axis[0], pinion_axis[1]]) rotate([0, 90, 0]) cylinder(r = r, h = bx[1] - bx[0], $fn = 48);
            translate([bx[0], col[2] + wall - 0.01, pinion_axis[1] - r - dy]) cube([bx[1] - bx[0], 0.01, 2 * (r + dy)]);
          }
        translate([col[0] - 1, col[2], -1000]) cube([col[1] - col[0] + 2, 1000, 2000]);    // behind the front face (the bed)
      }
      // top-stop ledge under the slider's -x tab, down to the front wall
      nut_block(col_top - cjoint[1] / 2);
      translate([col[0] + wall - 0.01, col[2] + wall - 0.01, slider_z0_up + tab_dz - 6]) cube([ledge_x1 - (col[0] + wall) + 0.01, ledge[3] - col[2] - wall + 0.01, 6]);
    }
    for (win = [[pin_w + 4, 11], [col[1] - col[0] - 2 * boss_len, 7]]) let(w = win[0], hh = win[1])   // pinion window + gear slot (stops at the bosses)
      translate([-w/2, col[2] - 1, pinion_axis[1] - hh]) cube([w, wall + 2, 2 * hh]);
    tear_xd(shaft_bore, col[0] - 1, boss_len + 2, pinion_axis[0], pinion_axis[1], 1, 0);   // teardrop tips toward +y (print up)
    tear_xd(bore_px, col[1] - boss_len - 1, boss_len + 2, pinion_axis[0], pinion_axis[1], 1, 0);
    joint_bolts(cjoint[1] / 2, [1, 0]);
    joint_bolts(col_top - cjoint[1] / 2, [1, 0], top_bolt_y);
    nut_block(col_top - cjoint[1] / 2, cut = true);
    scale_ticks();
  }
}

// plunge scale on the column's -x face: 1 mm ticks, 5 / 10 mm longer, 0.6 deep. Depth d is read at the pointer's top edge.
// The face is vertical when the column prints front-face down, and the grooves run along the print's Z: no overhang.
module scale_ticks() {
  for (d = [scale_range[0]:scale_range[1]]) let(L = d % 10 == 0 ? 5 : d % 5 == 0 ? 3.5 : 2)
    translate([col[0] - 0.01, scale_y, head_z0_up + ptr_dz - d - 0.3]) cube([0.61, L, 0.6]);
}

module rear_cover() {   // closes the U into a box; carries the slider's rear guides (ribs, print flat inner face up)
  z0 = -key_d; z1 = col_top + key_d;
  difference() {
    union() {
      translate([col[0], col[3], z0]) cube([col[1] - col[0], cover_t, z1 - z0]);
      let(gz0 = slider_z0_up + 6, gz1 = pinion_axis[1] + 10, gy = slider_back + 0.3)
        for (g = [[slider_x + slider_w/2 + 0.3, col[1] - wall - 0.3], [col[0] + wall + 0.3, slider_x - slider_w/2 - 0.3]])
          translate([g[0], gy, gz0]) cube([g[1] - g[0], col[3] - gy + 0.01, gz1 - gz0]);
    }
  }
}

module top_arm() {   // plate holding the rod tops + a skirt round the column top; prints upside down (top face on the bed)
  difference() {
    union() {
      slab(-arm_xh, arm_xh, arm_y0, col[3] + cover_t + key_c + cjoint[0] + 3, col_top, arm_t, r = 4);   // skirt sits inside the plate outline
      translate([0, 0, col_top - cjoint[1]]) linear_extrude(cjoint[1] + 0.01) col_outline(key_c + cjoint[0]);   // skirt block
    }
    translate([0, 0, col_top - cjoint[1] - 1]) linear_extrude(cjoint[1] + 1 + key_d) col_outline(key_c);   // column-top pocket, one cut
    joint_bolts(col_top - cjoint[1] / 2, [0, -1], top_bolt_y);
    for (x = rod_x) {
      translate([x, rod_y, col_top - 1]) cylinder(d = rod_bore, h = arm_t + 2, $fn = 64);
      tear_xd(m3_insert[0], x > 0 ? x + rod_d/2 - 0.5 : -arm_xh - 1, (x > 0 ? arm_xh + 1 : -(x - rod_d/2 + 0.5) - arm_xh), rod_y, arm_top - arm_t/2, 0, -1);   // M3 grub (arm prints upside down)
    }
  }
}
