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
      for (x = rod_x) hull() {                                   // top arm: column top -> rod boss, 45°+ undersides
        column_block(arm_c, arm_top);
        translate([x, rod_y, boss_z0]) cylinder(r = boss_r, h = arm_top - boss_z0, $fn = 64);
        translate([x, rod_y, boss_z0 - (boss_r - 6)]) cylinder(r1 = 6, r2 = boss_r, h = boss_r - 6, $fn = 64);   // 45° cone under the boss, clear of the rod hole
      }
      hull() {                                                   // depth-stop lug, 45° underside
        translate([col[0] - lug[0], pinion_axis[0] - lug[1]/2, pinion_axis[1] + 16]) cube(lug);
        translate([col[0] - 0.01, pinion_axis[0] - lug[1]/2, pinion_axis[1] + 16 - lug[0]]) cube([0.01, lug[1], lug[0] + lug[2]]);
      }
    }
    // hollow column (open bottom into the base pocket is not needed: floor stays)
    let(ix = col[1] - col[0] - 2*wall, iy = col[3] - col[2] - 2*wall, top = arm_c - wall - max(ix, iy)/2)
      hull() {                                                   // hollow with a 45° pyramid roof (no flat ceiling)
        translate([col[0] + wall, col[2] + wall, 0]) cube([ix, iy, top]);
        translate([(col[0] + col[1])/2 - 0.5, col[2] + wall + iy/2 - 0.5, top + max(ix, iy)/2 - 0.5]) cube([1, 1, 0.5]);
      }
    // front window: pinion meets the rack
    translate([-(pin_w + 4)/2, col[2] - 1, pinion_axis[1] - 16]) rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(wall + 2)
      polygon([[0, 0], [pin_w + 4, 0], [pin_w + 4, 32], [(pin_w + 4)/2, 32 + (pin_w + 4)/2], [0, 32]]);   // pointed top
    // rear access window (slider + spring go in from the back)
    let(w = col[1] - col[0] - 2*wall - 6) translate([col[0] + wall + 3, col[3] - wall - 1, 20])
      rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(wall + 2)                  // pointed-arch top (45°)
        polygon([[0, 0], [w, 0], [w, arm_c - 70], [w/2, arm_c - 70 + w/2], [0, arm_c - 70]]);
    // shaft bores in both side walls; the gear pair goes in through the rear window and slides onto the hex
    for (x = [col[0] - 1, col[1] - wall - 1]) tear_x(shaft_bore, x, wall + 2, pinion_axis[0], pinion_axis[1]);
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
  // spring-slider rear guides, hung on the column side walls (mesh force pushes the slider rearward onto them)
  for (s = [-1, 1]) translate([s > 0 ? slider_w/2 + 0.3 : col[0] + wall - 0.01, slider_back + 0.3, -0.01])
    cube([col[1] - wall - slider_w/2 - 0.3 + 0.01, 4, pinion_axis[1] + 10]);   // from the floor: no overhang
}
