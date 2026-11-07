// Nozzle camera mount for Anycubic Kobra 2 Neo
// Camera: generic 1/4" CMOS 640x480 USB mini webcam (square body, silver focus ring)
//
// Three parts joined by M3 bolt hinges (friction-tight, adjustable angle):
//   1. base   - bolts to the print head (slotted holes, adjust spacing below)
//   2. arm    - drops down/out from the head, hinge at both ends
//   3. cradle - sleeve that holds the camera body, lens window at front
//
// !!! ALL "MEASURE" VALUES ARE PLACEHOLDERS. Measure your camera and your
// !!! print head with calipers and update them before printing.
//
// Render a single part:  set PART below, F6, then export STL.
// PART = "all" shows an assembled preview (not for printing).

PART = "all";   // "all" | "base" | "arm" | "cradle" | "print" (all three laid flat)

/* ---------- Camera (MEASURE) ---------- */
cam_w      = 25.0;   // body width  (X)              MEASURE
cam_h      = 25.0;   // body height (Z)              MEASURE
cam_d      = 12.0;   // body depth, front to back    MEASURE
lens_d     = 15.0;   // focus-ring outer diameter    MEASURE (+ clearance added)
lens_off_x = 0.0;    // lens centre offset from body centre, X  MEASURE
lens_off_z = 0.0;    // lens centre offset from body centre, Z  MEASURE
cable_w    = 5.0;    // cable exit width at back      MEASURE
fit        = 0.4;    // clearance around camera body (per side)

/* ---------- Print-head attachment (MEASURE) ---------- */
// Base plate bolts to two screw holes on the head (e.g. the hotend cover /
// fan shroud screws). Holes are slots, so spacing tolerates +/- slot_len/2.
hole_spacing = 20.0;  // centre-to-centre of the two head screws   MEASURE
screw_d      = 3.4;   // M3 clearance
screw_head_d = 6.0;
slot_len     = 6.0;   // total slot travel
base_w       = hole_spacing + 14;
base_h       = 14;
base_t       = 3.0;

/* ---------- Arm ---------- */
arm_len  = 35;        // hinge-to-hinge distance; sets how far below/out the cam sits
arm_w    = 10;

/* ---------- Hinge ---------- */
hinge_d     = 10;     // knuckle outer diameter
hinge_bolt  = 3.3;    // M3 through-bolt
nut_af      = 5.7;    // M3 nut across flats (+clearance)
nut_t       = 2.6;
tongue_t    = 4.0;    // middle knuckle thickness
fork_t      = 3.0;    // each outer fork prong thickness
hinge_gap   = 0.3;    // clearance between tongue and prongs

wall = 2.0;
$fn  = 48;

/* ================= helpers ================= */
fork_total = tongue_t + 2*(fork_t + hinge_gap);

// Single knuckle (tongue), axis along X, centred at origin
module tongue() {
    difference() {
        rotate([0,90,0]) cylinder(d=hinge_d, h=tongue_t, center=true);
        rotate([0,90,0]) cylinder(d=hinge_bolt, h=tongue_t+1, center=true);
    }
}

// Fork (two prongs), axis along X, centred at origin, nut trap on +X side
module fork() {
    off = tongue_t/2 + hinge_gap + fork_t/2;
    difference() {
        union() for (s=[-1,1]) translate([s*off,0,0])
            rotate([0,90,0]) cylinder(d=hinge_d, h=fork_t, center=true);
        rotate([0,90,0]) cylinder(d=hinge_bolt, h=fork_total+1, center=true);
        translate([off + fork_t/2 - nut_t + 0.01, 0, 0])
            rotate([0,90,0]) cylinder(d=nut_af/cos(30), h=nut_t+0.1, $fn=6);
    }
}

module slot(len, d, h) {
    hull() for (x=[-len/2, len/2]) translate([x,0,0]) cylinder(d=d, h=h);
}

/* ================= parts ================= */

// BASE: flat plate in XZ plane (back face against head at y=0), fork hanging below
module base() {
    difference() {
        translate([-base_w/2, 0, -base_h/2]) cube([base_w, base_t, base_h]);
        for (s=[-1,1]) translate([s*hole_spacing/2, -0.5, 0]) rotate([-90,0,0]) {
            slot(slot_len, screw_d, base_t+1);
        }
    }
    // stem down to the fork
    translate([-fork_total/2, 0, -base_h/2 - hinge_d/2]) cube([fork_total, base_t, hinge_d/2]);
    translate([0, hinge_d/2, -base_h/2 - hinge_d/2]) fork();
    // bridge plate to knuckles
    translate([-fork_total/2, 0, -base_h/2 - hinge_d/2]) cube([fork_total, hinge_d/2, 0.01 + hinge_d/2]);
}

// ARM: tongue at top (origin), fork at bottom (z = -arm_len)
module arm() {
    tongue();
    translate([0,0,-arm_len]) fork();
    translate([-tongue_t/2, -arm_w/2*0.6, -arm_len + hinge_d/2 - 1])
        cube([tongue_t, arm_w*0.6, arm_len - hinge_d + 2]);
    // widen just above the fork so it meets both prongs
    hull() {
        translate([-tongue_t/2, -arm_w*0.3, -arm_len + hinge_d/2 + 6]) cube([tongue_t, arm_w*0.6, 0.1]);
        translate([-fork_total/2, -hinge_d/2*0.8, -arm_len + hinge_d/2 - 1]) cube([fork_total, hinge_d*0.8, 0.1]);
    }
}

// CRADLE: sleeve around camera. Camera looks toward -Y, lens window in front wall.
// Top is open-ish with retaining lips so the camera snaps in from the back.
module cradle() {
    iw = cam_w + 2*fit;  ih = cam_h + 2*fit;  id = cam_d + fit;
    ow = iw + 2*wall;    oh = ih + 2*wall;    od = id + wall;
    difference() {
        translate([-ow/2, 0, -oh/2]) cube([ow, od, oh]);
        // camera pocket, open at the back (+Y)
        translate([-iw/2, wall, -ih/2]) cube([iw, id + 1, ih]);
        // lens window
        translate([lens_off_x, -0.5, lens_off_z]) rotate([-90,0,0]) cylinder(d=lens_d + 1.0, h=wall+1);
        // cable notch at back bottom
        translate([-cable_w/2, wall, -oh/2 - 0.5]) cube([cable_w, id + 1, wall + 1]);
    }
    // retaining lips at the back opening (top and bottom), slight snap
    for (s=[-1,1]) translate([-iw/2, od - 1.2, s>0 ? ih/2 - 0.8 : -ih/2])
        cube([iw, 1.2, 0.8]);
    // tongue on top for the arm's fork
    translate([0, od/2, oh/2 + hinge_d/2 - 1]) tongue();
    translate([-tongue_t/2, od/2 - hinge_d/2 + 1, oh/2 - 0.01]) cube([tongue_t, hinge_d - 2, hinge_d/2 - 1]);
}

/* ================= layout ================= */
if (PART == "base")   base();
if (PART == "arm")    rotate([0,90,0]) arm();               // lay flat on side
if (PART == "cradle") rotate([90,0,0]) translate([0,0,0]) cradle(); // lens face down
if (PART == "print") {
    translate([-40,0,0]) rotate([90,0,0]) base();
    translate([0,0,tongue_t/2]) rotate([0,90,0]) arm();
    translate([45,0,0]) rotate([90,0,0]) cradle();
}
if (PART == "all") {
    color("orange") base();
    hz = -base_h/2 - hinge_d/2;  hy = hinge_d/2;
    color("gray")   translate([0, hy, hz]) arm();
    iw = cam_w + 2*fit; id = cam_d + fit; oh = cam_h + 2*fit + 2*wall;
    color("orange") translate([0, hy - (id+wall)/2, hz - arm_len - oh/2 - hinge_d/2 + 1]) cradle();
}
