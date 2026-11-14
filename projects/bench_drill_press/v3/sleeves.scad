// Adapter sleeves for the 43 mm ring. Split at the front (lined up with the ring's split) so the
// ring's clamp passes straight through to the tool. Tabs on the front arc rest on the ring's top face.
// Print upside down (tabs on the bed).

module ring_sleeve(id, vents = 0) {
  z0 = head_z0; od = fit_mid("g6", ring_d);
  difference() {
    union() {
      translate([0, 0, z0]) cylinder(d = od, h = ring_h + 2, $fn = 128);   // +2: flush with the tabs (both on the bed)
      for (a = [180, 235, 305, 0]) rotate(a) translate([ring_d/2 - 1, -4, z0 + ring_h]) cube([5, 8, 2]);   // tabs (front arc only: the head body sits behind)
    }
    translate([0, 0, z0 - 1]) cylinder(d = id, h = ring_h + 4, $fn = 96);
    translate([-ring_slit/2, -ring_d/2 - 6, z0 - 1]) cube([ring_slit, ring_d/2, ring_h + 4]);          // split, in line with the ring's
    if (vents > 0) for (i = [0:vents-1]) rotate(45 + i * 90) translate([id/2 + sleeve_wall_min, -1.5, z0 + 5])   // vertical vent slots inside the wall
      cube([(od - id)/2 - sleeve_wall_min + 1, 3, ring_h - 10]);   // open to the outside
  }
}
module sleeve_555() { ring_sleeve(m555_d + 0.2); }
module sleeve_iron() { ring_sleeve(iron_d + 0.3, vents = 4); }
