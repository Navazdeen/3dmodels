// Nozzle camera mount for Anycubic Kobra 2 Neo — LEFT side of print head
// Camera: 1/4" CMOS 640x480 USB mini webcam with collapsible cable
//          (vendor-listed body size 40 x 30 x 15 mm, Robu.in / Zbotic)
//
// Kinematic chain (head -> camera):
//   base   : plate bolted to the left side of the head, with a toothed rosette
//   arm    : flat bar; rosette at top (locks at 15 deg steps, any angle in the
//            plane of the head's side), 2 locating pins + M3 hole at bottom
//   stud   : separate ball stud, bolts to the arm end, printed UPRIGHT so the
//            ball is a clean full sphere (no supports, no print-in-place)
//   cradle : holds the camera; lower half of a split ball socket on top
//   cap    : upper half of the socket. Two M3 screws squeeze cap onto the ball
//            -> adjustable friction, then lock tight. Gives +/-30 deg tilt and
//            360 deg roll at the camera.
//
// Why a split clamp instead of a snap/print-in-place ball: snap sockets wear
// loose, and print-in-place balls fuse or rattle depending on the printer.
// A bolted clamp tolerates +/-0.3 mm print error and can be re-tightened.
//
// Hardware: 1x M3x16 + nut (rosette), 1x M3x8 + nut (stud),
//           2x M3x12 self-tapping into plastic (socket cap),
//           head screws: reuse / lengthen the head's own M3 screws.
//
// !!! Values marked MEASURE are not verified against real parts. !!!

PART = "print"; // "print" | "base" | "arm" | "stud" | "cradle" | "cap"

/* ---------- Camera ---------- */
cam_w      = 40.0;   // body width              (vendor spec) MEASURE
cam_h      = 30.0;   // body height             (vendor spec) MEASURE
cam_d      = 10.0;   // body depth WITHOUT lens (15 incl. lens, est.) MEASURE
lens_d     = 22.0;   // silver focus-ring outer dia (est. from photo) MEASURE
lens_off_x = 4.0;    // lens centre right of body centre (est. from photo) MEASURE
lens_off_z = 0.0;    // lens centre above body centre MEASURE
fit        = 0.4;    // clearance per side

/* ---------- Head attachment ---------- */
hole_spacing = 20.0;  // centre-to-centre of the two head screws    MEASURE
screw_d      = 3.4;
slot_len     = 8.0;   // slot travel: spacing works within +/-4 mm
base_t       = 4.0;

/* ---------- Arm / rosette ---------- */
arm_len   = 40;       // rosette centre to ball-stud centre
arm_w     = 10;
arm_t     = 5;
ros_r     = 10;       // rosette radius
ros_n     = 24;       // teeth -> 15 deg steps

/* ---------- Ball joint ---------- */
ball_d    = 12;
neck_d    = 6;
neck_len  = 5;
flange_d  = 19;
flange_h  = 4;
pin_d     = 2.5;  pin_off = 6.5;   // keeps >=1.5 mm wall to nut trap and rim
sock_wall = 3;
sock_gap  = 0.5;      // per half; leaves 1 mm for the screws to squeeze
cone_half = 55;       // socket mouth half-angle (tilt range = this - neck angle)

m3_clear = 3.4; m3_pilot = 2.8; nut_af = 5.7; nut_t = 2.6;
wall = 2.0;
$fn  = 64;

/* ================= helpers ================= */
module nut_trap(h=nut_t+0.2) cylinder(d=nut_af/cos(30), h=h, $fn=6);
module slot(len, d, h) hull() for (x=[-len/2, len/2]) translate([x,0,0]) cylinder(d=d, h=h);

// Face-gear rosette on z=0, teeth pointing +z. Pyramidal teeth (apex at
// centre) so two identical rosettes mesh across the whole face.
module rosette(r=ros_r, n=ros_n) {
    a = 180/n;  h = r*sin(a);
    // teeth sink 0.5 mm into the body and the shared apex is cut away,
    // so the union is a clean manifold
    difference() {
        intersection() {
            union() for (i=[0:n-1]) rotate([0,0,i*360/n])
                hull() {
                    polyhedron(points=[[0,0,0],[r*cos(a),-r*sin(a),0],[r*cos(a),r*sin(a),0],[r,0,h]],
                               faces=[[0,1,2],[0,3,1],[0,2,3],[1,3,2]]);
                    translate([0,0,-0.5]) cylinder(r=0.01, h=0.01);
                    translate([r*cos(a)*0.99,0,-0.5]) cylinder(r=r*sin(a)*0.99, h=0.5, $fn=4);
                }
            translate([0,0,-0.5]) cylinder(r=r, h=h+1);
        }
        translate([0,0,-1]) cylinder(r=3, h=h+2);
    }
}
ros_h = ros_r*sin(180/ros_n);

/* ================= parts (all modelled in print orientation) ================= */

// BASE — flat on bed. Head-facing side is the bed side.
base_w = hole_spacing + slot_len + 10;
base_l = 14;
module base() {
    lobe_y = -(base_l/2 + ros_r - 2);
    difference() {
        union() {
            translate([-base_w/2, -base_l/2, 0]) cube([base_w, base_l, base_t]);
            hull() {
                translate([-ros_r, -base_l/2, 0]) cube([2*ros_r, 1, base_t]);
                translate([0, lobe_y, 0]) cylinder(r=ros_r, h=base_t);
            }
            translate([0, lobe_y, base_t - 0.01]) rosette();
        }
        for (s=[-1,1]) translate([s*hole_spacing/2, 0, -1]) slot(slot_len, screw_d, base_t+2);
        translate([0, lobe_y, -1]) cylinder(d=m3_clear, h=base_t+ros_h+2);
        translate([0, lobe_y, -0.01]) nut_trap();
    }
}

// ARM — flat on bed. Rosette at origin (top face), stud pad at (0,-arm_len).
module arm() {
    difference() {
        union() {
            cylinder(r=ros_r, h=arm_t);
            translate([0,0,arm_t-0.01]) rosette();
            translate([0,-arm_len,0]) cylinder(d=flange_d+2, h=arm_t);
            translate([-arm_w/2, -arm_len, 0]) cube([arm_w, arm_len, arm_t]);
            for (s=[-1,1]) translate([s*pin_off, -arm_len, arm_t-0.01]) cylinder(d=pin_d, h=2);
        }
        translate([0,0,-1]) cylinder(d=m3_clear, h=arm_t+ros_h+2);
        translate([0,-arm_len,-1]) cylinder(d=m3_clear, h=arm_t+2);
        translate([0,-arm_len,-1]) cylinder(d=6, h=1+1.5);   // M3 head recess
    }
}

// STUD — upright on its flange. Full sphere on top.
ball_c = flange_h + neck_len + ball_d/2 - 1;
module stud() {
    difference() {
        union() {
            cylinder(d=flange_d, h=flange_h);
            cylinder(d=neck_d, h=ball_c);
            translate([0,0,ball_c]) sphere(d=ball_d);
            // fillet neck/flange
            translate([0,0,flange_h-0.01]) cylinder(d1=neck_d+4, d2=neck_d, h=2);
        }
        translate([0,0,-1]) cylinder(d=m3_clear, h=flange_h+4);
        translate([0,0,-0.01]) nut_trap();
        for (s=[-1,1]) translate([s*pin_off,0,-0.01]) cylinder(d=pin_d+0.4, h=2.4);
    }
}

// Socket block geometry (shared by cradle and cap)
sock_s   = ball_d + 2*sock_wall;   // block width/depth
sock_ear = 9;                      // ear beyond block; >=1.5 mm wall around screw counterbore
sock_bx  = sock_s/2 + sock_ear/2;  // screw x offset
sock_hh  = ball_d/2 + sock_wall;   // cap height (+gap)
// lower half is taller: the 55 deg mouth cone must exit the back face
// above the cradle top wall, or it cuts through into the camera pocket
sock_low = ceil(sock_s/2 * tan(cone_half)) + 1;
module socket_mouth() {
    // cone opening toward +Y (back of camera), where the stud enters
    rotate([-90,0,0]) cylinder(r1=0, r2=40*tan(cone_half), h=40);
}

// CRADLE — upright, bottom on bed. Camera looks -Y; inserts from the open back.
module cradle() {
    iw = cam_w + 2*fit;  ih = cam_h + 2*fit;  id = cam_d + fit;
    ow = iw + 2*wall;    oh = ih + 2*wall;    od = id + wall;
    ys = od - sock_s;                        // socket block flush with back face
    ov = -ys;                                // overhang past the front face
    bc = [0, od - sock_s/2, oh + sock_low];  // ball centre
    difference() {
        union() {
            translate([-ow/2, 0, 0]) cube([ow, od, oh]);
            // lower socket half + ears
            translate([-(sock_s/2+sock_ear), ys, oh - 0.01])
                cube([sock_s + 2*sock_ear, sock_s, sock_low - sock_gap + 0.01]);
            // 45 deg gusset under the front overhang (prints without support)
            if (ov > 0) hull() {
                translate([-(sock_s/2+sock_ear), ys, oh - 0.01]) cube([sock_s + 2*sock_ear, ov, 0.01]);
                translate([-(sock_s/2+sock_ear), -0.01, oh - ov]) cube([sock_s + 2*sock_ear, 0.02, ov]);
            }
        }
        translate([-iw/2, wall, wall]) cube([iw, id + 1, ih]);                     // pocket
        // lens window as a teardrop: the pointed top keeps the overhang at 45 deg
        translate([lens_off_x, -0.5, oh/2 + lens_off_z]) rotate([-90,0,0])
            linear_extrude(wall + 1) hull() {
                circle(d=lens_d + 1.0);
                translate([0, -(lens_d + 1.0)/2*sqrt(2)]) square(0.01, center=true);
            }
        translate(bc) sphere(d=ball_d + 0.2);
        translate(bc) socket_mouth();
        for (s=[-1,1]) translate([s*sock_bx, od - sock_s/2, oh + 1]) cylinder(d=m3_pilot, h=sock_low + 1);
    }
    // snap lips at the back opening, top and bottom
    translate([-iw/2, od - 1.2, wall])            cube([iw, 1.2, 0.8]);
    translate([-iw/2, od - 1.2, wall + ih - 0.8]) cube([iw, 1.2, 0.8]);
}

// CAP — modelled split-face-down; printed flipped (cap_print) so the cup
// is an open bowl facing up. Printed the other way the dome ceiling sags.
module cap() {
    difference() {
        translate([-(sock_s/2+sock_ear), -sock_s/2, 0])
            cube([sock_s + 2*sock_ear, sock_s, sock_hh - sock_gap]);
        translate([0,0,-sock_gap]) sphere(d=ball_d + 0.2);
        translate([0,0,-sock_gap]) socket_mouth();
        for (s=[-1,1]) translate([s*sock_bx, 0, -1]) {
            cylinder(d=m3_clear, h=sock_hh + 2);
            translate([0,0,sock_hh - sock_gap - 3 + 1]) cylinder(d=6, h=5);   // 3 mm head counterbore
        }
    }
}

/* ================= layout ================= */
if (PART == "base")   base();
if (PART == "arm")    arm();
if (PART == "stud")   stud();
if (PART == "cradle") cradle();
module cap_print() translate([0,0,sock_hh - sock_gap]) rotate([180,0,0]) cap();
if (PART == "cap")    cap_print();
if (PART == "print") {
    translate([-30, 45, 0]) base();
    translate([15, 30, 0])  arm();
    translate([20, -30, 0]) stud();
    translate([-45, -40, 0]) cradle();
    translate([50, 10, 0])  cap_print();
}

/* ================= assembly pose (for the web viewer) =================
   World frame: head's left side face is the plane X=0, head body at +X,
   Z up, Y along the head (front/back). PART = "asm_<part>" exports that
   part in its assembled position so the viewer can explode it. */
arm_angle = -82.5;    // arm swing about the rosette (display only); n*15+7.5 so the teeth mesh
_lobe_y = -(base_l/2 + ros_r - 2);
_iw = cam_w + 2*fit; _ih = cam_h + 2*fit; _id = cam_d + fit;
_oh = _ih + 2*wall;  _od = _id + wall;
_bc = [0, _od - sock_s/2, _oh + sock_low];

module asm_base_tf()  multmatrix([[0,0,-1,0],[1,0,0,0],[0,1,0,0]]) children();
module asm_arm_tf()
    translate([0,0,_lobe_y]) rotate([arm_angle,0,0]) translate([0,0,-_lobe_y])
    multmatrix([[0,0,1,-(arm_t+base_t+ros_h)],[1,0,0,0],[0,1,0,_lobe_y]]) children();
module asm_stud_tf()   asm_arm_tf() translate([0,-arm_len,arm_t]) children();
module asm_cradle_tf() asm_stud_tf()
    multmatrix([[1,0,0,0],[0,0,1,-_bc[2]],[0,-1,0,ball_c + _bc[1]]]) children();
module asm_cap_tf()    asm_cradle_tf()
    multmatrix([[1,0,0,_bc[0]],[0,-1,0,_bc[1]],[0,0,-1,_bc[2] + sock_gap + sock_hh - sock_gap]]) children();

if (PART == "asm_base")   asm_base_tf()   base();
if (PART == "asm_arm")    asm_arm_tf()    arm();
if (PART == "asm_stud")   asm_stud_tf()   stud();
if (PART == "asm_cradle") asm_cradle_tf() cradle();
if (PART == "asm_cap")    asm_cap_tf()    cap_print();
if (PART == "asm") { asm_base_tf() base(); asm_arm_tf() arm(); asm_stud_tf() stud();
                     asm_cradle_tf() cradle(); asm_cap_tf() cap_print(); }
