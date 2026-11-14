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

module column_block(z0, z1) { translate([col[0], col[2], z0]) cube([col[1] - col[0], col[3] - col[2], z1 - z0]); }

module c_frame() {
  difference() {
    union() {
      slab(-base_x, base_x, base_y[0], base_y[1], -base_t, base_t);
      column_block(-1, arm_top);
      // bearing bosses round both shaft bores (teardrop: 45° underside); they reach forward of the column face,
      // clear of the head (only the 10 mm-wide rack needs the space in front of the column)
      for (bx = [[col[0], col[0] + wall], [col[1] - wall, col[1]]]) let(r = shaft_bore/2 + 3)
        translate([bx[0], pinion_axis[0], pinion_axis[1]]) rotate([0, 90, 0]) linear_extrude(bx[1] - bx[0])
          hull() { circle(r = r, $fn = 48); translate([r / sin(45), 0]) square(0.01, center = true); }
      for (x = rod_x) hull() {                                   // top arm: column top -> rod boss, 45°+ undersides
        column_block(arm_c, arm_top);
        translate([x, rod_y, boss_z0]) cylinder(r = boss_r, h = arm_top - boss_z0, $fn = 64);
        translate([x, rod_y, boss_z0 - (boss_r - 6)]) cylinder(r1 = 6, r2 = boss_r, h = boss_r - 6, $fn = 64);   // 45° cone under the boss, clear of the rod hole
      }
      let(py = pinion_axis[0] + lug_off[0], pz = pinion_axis[1] + lug_off[1], ax = stop_x[1] + 1) {
        hull() {                                                 // arm from the column to just short of the ring, 45° underside
          translate([ax, py - 3, pz - 3]) cube([col[0] - ax + 0.01, 6, 6]);
          translate([col[0] - 0.01, py - 3, pz - 3 - (col[0] - ax)]) cube([0.01, 6, 1]);
        }
        translate([stop_x[0] - 1, py, pz]) rotate([0, 90, 0]) linear_extrude(ax - stop_x[0] + 1.01)   // stop pin, teardrop section
          hull() { circle(d = lug_pin_d, $fn = 32); translate([-lug_pin_d/2 / sin(40), 0]) square(0.01, center = true); }
      }
    }
    // hollow column (open bottom into the base pocket is not needed: floor stays)
    let(ix = col[1] - col[0] - 2*wall, iy = col[3] - col[2] - 2*wall, top = arm_c - wall - max(ix, iy)/2)
      hull() {                                                   // hollow with a 45° pyramid roof (no flat ceiling)
        translate([col[0] + wall, col[2] + wall, 0]) cube([ix, iy, top]);
        translate([(col[0] + col[1])/2 - 0.5, col[2] + wall + iy/2 - 0.5, top + max(ix, iy)/2 - 0.5]) cube([1, 1, 0.5]);
      }
    // front window: pinion meets the rack
    // pinion window (pointed top) + a low full-width slot where the Ø12 shaft clips the front wall
    for (win = [[pin_w + 4, 11], [col[1] - col[0] - 2 * wall, 7]]) let(w = win[0], hh = win[1])
      translate([-w/2, col[2] - 1, pinion_axis[1] - hh]) rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(wall + 2)
        polygon([[0, 0], [w, 0], [w, 2 * hh], [w/2, 2 * hh + w/2], [0, 2 * hh]]);
    // rear access window (slider + spring go in from the back)
    let(w = col[1] - col[0] - 2*wall - 6) translate([col[0] + wall + 3, col[3] - wall - 1, 20])
      rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(wall + 2)                  // pointed-arch top (45°)
        polygon([[0, 0], [w, 0], [w, arm_c - 70], [w/2, arm_c - 70 + w/2], [0, arm_c - 70]]);
    // shaft bores in both side walls; the gear pair goes in through the rear window and slides onto the hex
    tear_x(shaft_bore, col[0] - 1, wall + 2, pinion_axis[0], pinion_axis[1]);             // -x: Ø14.5 (shaft goes in from here)
    tear_x(bore_px, col[1] - wall - 1, wall + 2, pinion_axis[0], pinion_axis[1]);         // +x: Ø9.7
    // rods: blind sockets in the base, through-holes in the bosses, M3 grub per boss
    for (x = rod_x) {
      translate([x, rod_y, -rod_socket]) cylinder(d = rod_bore, h = rod_socket + 0.01, $fn = 64);
      translate([x, rod_y, -0.6]) cylinder(d1 = rod_bore, d2 = rod_bore + 1.2, h = 0.61, $fn = 64);
      translate([x, rod_y, arm_c - 1]) cylinder(d = rod_bore, h = arm_top - arm_c + 2, $fn = 64);   // through the whole arm
      tear_x(m3_insert[0], x > 0 ? x + rod_d/2 - 0.5 : x - boss_r - 1, boss_r - rod_d/2 + 1.5, rod_y, arm_top - 5);
    }
    // work-pad pocket
    translate([-pad[0]/2, -pad[1]/2, -pad[2]]) cube([pad[0], pad[1], pad[2] + 1]);
  }
  // spring-slider rear guides on the side walls, only over the slider's range, 45° undersides
  let(gz0 = slider_z0_up + 6, gz1 = pinion_axis[1] + 10, gy = slider_back + 0.3)       // start above the hook / spring
  for (g = [[slider_x + slider_w/2 + 0.3, col[1] - wall + 0.01], [col[0] + wall - 0.01, slider_x - slider_w/2 - 0.3]])
    hull() {
      translate([g[0], gy, gz0]) cube([g[1] - g[0], 4, gz1 - gz0]);
      translate([abs(g[0]) > abs(g[1]) ? g[0] : g[1] - 0.01, gy, gz0 - (g[1] - g[0])]) cube([0.01, 4, 1]);   // sliver on the wall side
    }
  // top-stop ledge under the slider's -x tab (3 x 5), 45° underside to the -x wall
  hull() {
    translate([col[0] + wall - 0.01, ledge[2], slider_z0_up + tab_dz - 4]) cube([ledge[1] - 0.3 - (col[0] + wall) + 0.01, ledge[3] - ledge[2], 4]);
    translate([col[0] + wall - 0.01, ledge[2], slider_z0_up + tab_dz - 4 - (ledge[1] - 0.3 - (col[0] + wall))]) cube([0.01, ledge[3] - ledge[2], 1]);
  }
  // spring anchor: diamond bar across both walls (simply supported, no overhang)
  translate([col[0] + wall - 0.01, spring_y, ks_anchor_z]) rotate([0, 90, 0]) linear_extrude(col[1] - col[0] - 2 * wall + 0.02)
    rotate(45) square(anchor_d / sqrt(2), center = true);
}
