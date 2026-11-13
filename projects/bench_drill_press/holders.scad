// Tool holders on the vertical dovetail, lock knob. Included after params/frame/carriage.
// All holders print on their back (key face on the bed): print=x-90.

kb = key_bottom(holder_z, plunge);          // key bottom z at this pose
plate_y1 = carriage_y0 - 0.5;               // holder rear face (0.5 mm off the carriage face)
neck_w = dt_mouth - 2*dt_clear;             // key neck width

module holder_key(len = holder_key_len) {
  translate([0, carriage_y0, kb]) linear_extrude(len) dovetail_profile(-dt_clear);
}

// hole along model z through a wall that prints vertical (holder on its back): teardrop tip toward -y (print up)
module tear_z(d, z0, h) {
  translate([0, 0, z0]) linear_extrude(h) hull() { circle(d = d, $fn = 48); translate([0, -d/2 / sin(40)]) square(0.01, center = true); }
}

// 2D: neck strip at the holder rear face; hull()-ing a shape with it gives support-free flanks on the back
module neck2d() { translate([-neck_w/2 + 0.1, plate_y1 - 0.01]) square([neck_w - 0.2, 0.01]); }   // 0.1 inside the key neck: no coincident faces

// plate between the key and y0, widening forward at 50° from the bed (prints on its back)
module holder_plate(y0, z0, h) {
  w = neck_w + 2*(plate_y1 - y0)*tan(40);
  translate([0, 0, z0]) linear_extrude(h) hull() { neck2d(); translate([-w/2, y0]) square([w, 0.01]); }
}

module holder_motor(d, len, screw, boss) {
  ro = d/2 + holder_wall; fz = kb + f_off(tool_below); top = fz + 0.6 * len;
  difference() {
    union() {
      holder_key(max(holder_key_len, top - kb));          // key runs the full holder height
      translate([0, 0, fz - holder_floor]) linear_extrude(top - fz + holder_floor) hull() { neck2d(); circle(r = ro, $fn = 96); }
    }
    translate([0, 0, fz]) cylinder(d = fit_mid("H9", d), h = len, $fn = 128);                      // motor body
    rotate(-90 - 80) rotate_extrude(angle = 160, $fn = 96) translate([0, fz]) square([ro + 1, len]); // 160° front window from the floor up (200° wrap)
    tear_z(boss[0] + 1, fz - holder_floor - 1, holder_floor + 2);                                         // boss / shaft
    for (s = [-1, 1]) translate([s * screw[1]/2, 0, 0]) tear_z(screw[0], fz - holder_floor - 1, holder_floor + 2);
    for (a = [45, 135]) translate((boss[0]/2 + 6) * [cos(a), sin(a), 0]) tear_z(6, fz - holder_floor - 1, holder_floor + 2);  // vents, rear diagonals
  }
}

// iron: 90° V-block on the handle only, strap + 2 x M3 pull the handle into the V
iron_cb = kb + f_off(iron_hot_len + iron_air_gap);       // clamp bottom
iron_apex_y = iron_d/2 * sqrt(2);                         // V apex behind the axis (nominal handle centred at y=0)
iron_block_y0 = 2;                                        // block front face
strap_x = 18;                                             // strap screw |x|
module holder_iron() {
  hw = iron_apex_y - iron_block_y0 + 9;                   // block half width
  klen = iron_cb + iron_grip_len - kb;                    // key runs the full holder height
  difference() {
    union() {
      holder_key(klen);
      holder_plate(14, kb, iron_cb - kb + 1);               // below the clamp: stays at y >= 14 (>= iron_air_gap from the barrel)
      translate([0, 0, iron_cb]) linear_extrude(iron_grip_len) hull() { neck2d(); translate([-hw, iron_block_y0]) square([2*hw, 10]); }   // straight sides past the screw inserts
    }
    translate([0, iron_apex_y, iron_cb - 1]) rotate(45) translate([-50, -50, 0]) cube([50, 50, iron_grip_len + 2]); // 90° V
    for (s = [-1, 1]) translate([s * strap_x, iron_block_y0 - 1, iron_cb + iron_grip_len/2]) rotate([-90, 0, 0])
      cylinder(d = m3_insert[0], h = 15, $fn = 32);                                                       // M3 insert + screw run-out
  }
}

module iron_strap() {
  yf = -iron_d/2;                                         // pressing face on the nominal handle
  translate([0, 0, iron_cb + iron_grip_len/2 - 12]) difference() {
    translate([-strap_x - 5, yf - 6, 0]) cube([2*strap_x + 10, 6, 24]);
    for (s = [-1, 1]) translate([s * strap_x, yf - 7, 12]) rotate([-90, 0, 0]) cylinder(d = m3_clear, h = 8, $fn = 32);
  }
}

module lock_knob() {
  translate([0, carriage_y1 + 1, carriage_z0 + lock_z]) rotate([-90, 0, 0]) difference() {
    cylinder(d = 20, h = 8, $fn = 24);
    translate([0, 0, -0.01]) head_pocket(5.2);                          // M5 socket head, crush-rib press fit
    translate([0, 0, 4]) cylinder(d = knob_key_d, h = 5, $fn = 24);    // 4 mm hex key passes
  }
}
