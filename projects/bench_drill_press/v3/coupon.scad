// Preload coupon: print first. Three cells with the head's V seat + flexure gib at gib_gap -0.2 / 0 / +0.2 mm
// (1 / 2 / 3 notches). Slide each onto a rod: keep the one that has no play yet still slides by hand,
// then set gib_gap (via gib_preload) in params.scad. Prints upright.
include <params.scad>
include <frame.scad>
coupon_gaps = [gib_gap - 0.2, gib_gap, gib_gap + 0.2];
assert(max(coupon_gaps) - min(coupon_gaps) >= 0.4 - 1e-6, "coupon must span ±0.2 mm");
cell_h = gib_L + 7;
module coupon_cell(gap, n) {
  difference() {
    translate([-9, -15, 0]) cube([18, 30, cell_h]);                                            // 4 mm back wall behind the slot
    translate([-slot_hw[0], -slot_hw[1], -1]) cube([2 * slot_hw[0], 2 * slot_hw[1], cell_h + 2]);
    for (k = [1:n]) translate([-9 + 3 * k, -15.01, cell_h - 2]) cube([1, 1.5, 2.01]);         // notch count = cell number
  }
  difference() {                                                                              // rigid V seat (front, -y)
    translate([-slot_hw[0], -slot_hw[1], 0]) cube([2 * slot_hw[0], slot_hw[1], cell_h]);
    translate([0, 0, -1]) linear_extrude(cell_h + 2) rotate(45) square(rod_d, center = true);
  }
  // gib behind the rod (+y): stands on the bed, root at the top, bump at the bottom
  translate([-gib_b/2, rod_d/2 + 2 - gap, 0]) cube([gib_b, gib_t, cell_h]);
  translate([-gib_b/2, rod_d/2 - gap, 0]) cube([gib_b, 2.01, seat_h]);   // 0.01 into the blade: one body
  translate([-slot_hw[0] - 0.01, rod_d/2 + 2 - gap + gib_t - 0.01, cell_h - 5]) cube([2 * slot_hw[0] + 0.02, slot_hw[1] - (rod_d/2 + 2 - gap + gib_t) + 0.02, 5]);
}
for (i = [0:2]) translate([i * 22, 0, 0]) coupon_cell(coupon_gaps[i], i + 1);
translate([-9, -15, 0]) cube([62, 3, 3]);                                                     // joins the cells: one print
