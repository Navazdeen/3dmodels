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
// Hardware: 1x M3x16 + nut (rosette), 1x M3x12 + M3 nyloc nut (stud, side slot),
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
lens_shape = "circle"; // "circle" | "flat" | "teardrop" (see lens_teardrop)
fit        = 0.4;    // clearance per side
lip_zone   = 2.4;    // pocket depth behind the camera for the snap lips + lead-in
lip_d      = 0.6;    // how far each snap lip reaches over the camera's back edge
tongue_l   = 11;     // free length of the side snap tongues (flex ~1.8 % strain in PETG)
tongue_h   = 12;     // tongue height
slit_w     = 1.0;    // slit that frees the tongue

/* ---------- Head attachment ---------- */
hole_spacing = 20.0;  // centre-to-centre of the two head screws    MEASURE
screw_d      = 3.4;
slot_len     = 8.0;   // slot travel: spacing works within +/-4 mm
base_t       = 4.5;   // >= 1.5 mm over the nut trap

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
// Stud nut: side-loaded slot, so the nut cannot drop out along the bolt axis,
// and a nylon-insert lock nut (nyloc) so vibration cannot back it off.
nyloc_t     = 4.0;               // M3 nyloc height (DIN 985); use 2.4 for a plain nut
nut_slot_t  = nyloc_t + 0.2;
nut_slot_w  = 5.6;               // snug on the 5.5 mm flats: the nut pushes in and stays
slot_skin   = 1.6;               // floor and roof around the slot (4 layers at 0.4)
flange_h    = nut_slot_t + 2*slot_skin;
pin_d     = 2.5;  pin_off = 6.5;   // keeps >=1.5 mm wall to nut trap and rim
sock_wall = 3;
sock_gap  = 0.5;      // per half; leaves 1 mm for the screws to squeeze
cone_half = 55;       // socket mouth half-angle (tilt range = this - neck angle)

m3_clear = 3.4; m3_pilot = 2.8; nut_af = 5.7; nut_t = 2.6;
wall = 2.4;   // 6 perimeters at 0.4; leaves >= 1 mm at filleted wall ends
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

/* ================= edge finishing ================= */
// Every exposed edge is rounded. Rules (FDM):
//  - edges on the bed get a 45 deg chamfer, never a fillet (a bottom fillet is
//    an overhang that curls and makes elephant-foot worse)
//  - top and vertical edges get fillets
//  - inside corners of outlines get fillets (fewer stress risers)
//  - functional faces stay sharp: rosette teeth, ball seat, socket split face
edge_r   = 1.5;   // fillet radius on outer edges
bed_ch   = 0.5;   // chamfer on bed edges
inner_r  = 3;     // fillet in concave outline corners
hole_ch  = 0.5;   // chamfer at hole entries
$fn_tool = 24;

// convex tool for minkowski: chamfered bottom (c), rounded top (r)
module edge_tool(r=edge_r, c=bed_ch, top=true) hull() {
    cylinder(r1=r-c, r2=r, h=max(c,0.001), $fn=$fn_tool);
    translate([0,0,max(c,0.001)])
        if (top) intersection() {
            sphere(r, $fn=$fn_tool);
            cylinder(r=r, h=r, $fn=$fn_tool);
        }
        else cylinder(r=r, h=r, $fn=$fn_tool);   // square top edge
}
// extrude a 2D outline to height H with every outer edge finished
module rslab(H, r=edge_r, c=bed_ch, fr=inner_r, top=true) {
    minkowski() {
        linear_extrude(H - max(c,0.001) - r)
            offset(delta=-r) offset(r=fr) offset(delta=-fr) children();
        edge_tool(r, c, top);
    }
}
// chamfer cone for a hole entry at z=0 going down (place at the face)
module hole_chamfer(d, ch=hole_ch) translate([0,0,-ch]) cylinder(d1=d, d2=d+2*ch, h=ch+0.01);

/* ================= parts (all modelled in print orientation) ================= */

// BASE — flat on bed. Head-facing side is the bed side.
base_w = hole_spacing + slot_len + 10;
base_l = 14;
lobe_r = ros_r + edge_r + 0.5;   // flat ring left round the rosette after the fillet
module base() {
    lobe_y = -(base_l/2 + ros_r - 2);
    difference() {
        union() {
            rslab(base_t) {
                square([base_w, base_l], center=true);
                hull() {
                    translate([-lobe_r, -base_l/2]) square([2*lobe_r, 1]);
                    translate([0, lobe_y]) circle(r=lobe_r, $fn=64);
                }
            }
            translate([0, lobe_y, base_t - 0.01]) rosette();
        }
        for (s=[-1,1]) translate([s*hole_spacing/2, 0, 0]) {
            translate([0,0,-1]) slot(slot_len, screw_d, base_t+2);
            // chamfered slot entry on the outer face
            translate([0,0,base_t - hole_ch]) hull() for (x=[-slot_len/2, slot_len/2])
                translate([x,0,0]) cylinder(d1=screw_d, d2=screw_d+2*hole_ch, h=hole_ch+0.01);
        }
        translate([0, lobe_y, -1]) cylinder(d=m3_clear, h=base_t+ros_h+2);
        translate([0, lobe_y, -0.01]) nut_trap();
    }
}

// ARM — flat on bed. Rosette at origin (top face), stud pad at (0,-arm_len).
pad_d = flange_d + 2*edge_r + 1;
module arm() {
    difference() {
        union() {
            rslab(arm_t) {
                circle(r=lobe_r, $fn=64);
                translate([0,-arm_len]) circle(d=pad_d, $fn=64);
                translate([-arm_w/2, -arm_len]) square([arm_w, arm_len]);
            }
            translate([0,0,arm_t-0.01]) rosette();
            // features sink 0.1 mm: the faceted fillet top sits ~0.02 mm below nominal
            for (s=[-1,1]) translate([s*pin_off, -arm_len, arm_t-0.1]) {
                cylinder(d=pin_d, h=1.7);
                translate([0,0,1.7]) cylinder(d1=pin_d, d2=pin_d-0.8, h=0.4);  // lead-in
            }
        }
        translate([0,0,-1]) cylinder(d=m3_clear, h=arm_t+ros_h+2);
        translate([0,-arm_len,-1]) cylinder(d=m3_clear, h=arm_t+2);
        translate([0,-arm_len,-1]) cylinder(d=6, h=1+1.5);   // M3 head recess
    }
}

// STUD — upright on its flange. Full sphere on top.
ball_c = flange_h + neck_len + ball_d/2 - 1;
neck_fillet = 2;
module stud() {
    difference() {
        union() {
            rslab(flange_h, r=1.2, c=bed_ch) circle(d=flange_d, $fn=64);
            cylinder(d=neck_d, h=ball_c);
            translate([0,0,ball_c]) sphere(d=ball_d);
            // true concave fillet between neck and flange
            translate([0,0,flange_h - 0.1]) rotate_extrude($fn=64) difference() {
                square([neck_d/2 + neck_fillet, neck_fillet + 0.1]);
                translate([neck_d/2 + neck_fillet, neck_fillet + 0.1]) circle(r=neck_fillet, $fn=32);
            }
        }
        // bolt hole runs on into the neck so the bolt tip clears the nut
        translate([0,0,-1]) cylinder(d=m3_clear, h=flange_h + 4);
        // side-loading nut slot: open toward +Y only. Once the bolt passes
        // through the nut it cannot move in any direction, tight or loose.
        translate([0,0,slot_skin]) linear_extrude(nut_slot_t) hull() {
            rotate(30) circle(d=nut_slot_w/cos(30), $fn=6);   // flats face +/-X
            translate([-nut_slot_w/2, 0]) square([nut_slot_w, flange_d]);
        }
        // flared mouth: no knife-edge where the slot meets the round rim,
        // and the nut starts in easily
        translate([0,0,slot_skin]) linear_extrude(nut_slot_t)
            polygon([[-nut_slot_w/2, flange_d/2 - 3], [nut_slot_w/2, flange_d/2 - 3],
                     [nut_slot_w/2 + 2, flange_d/2 + 0.5], [-nut_slot_w/2 - 2, flange_d/2 + 0.5]]);
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
sock_W   = sock_s + 2*sock_ear;
module socket_mouth() {
    // cone opening toward +Y (back of camera), where the stud enters
    rotate([-90,0,0]) cylinder(r1=0, r2=40*tan(cone_half), h=40);
}
// rim chamfer where the ball cup meets the split face (face at z=0, cup below)
module cup_rim(gap_to_centre) {
    rr = sqrt(pow((ball_d+0.2)/2,2) - pow(gap_to_centre,2));
    hole_chamfer(2*rr, 0.6);
}

// CRADLE — upright, bottom on bed. Camera looks -Y; inserts from the open back.
module cradle() {
    iw = cam_w + 2*fit;  ih = cam_h + 2*fit;  id = cam_d + fit + lip_zone;
    ow = iw + 2*wall;    oh = ih + 2*wall;    od = id + wall;
    ys = od - sock_s;                        // socket block flush with back face
    ov = -ys;                                // overhang past the front face
    bc = [0, od - sock_s/2, oh + sock_low];  // ball centre
    top = oh + sock_low - sock_gap;          // split face of the lower half
    difference() {
        union() {
            translate([0, od/2, 0]) rslab(oh) square([ow, od], center=true);
            // lower socket half + ears. Split face edges stay SHARP so the two
            // halves meet flush with no groove; vertical corners are rounded
            // with the same radius on both halves so they line up.
            translate([0, ys + sock_s/2, oh - edge_r - 0.1])
                rslab(top - oh + edge_r + 0.1, c=0, top=false) square([sock_W, sock_s], center=true);
            // rounded 45 deg gusset under the front overhang (prints without support)
            if (ov > 0) minkowski() {
                rotate([90,0,90]) linear_extrude(sock_W - 2*edge_r, center=true)
                    offset(delta=-1) polygon([[ys, oh+2], [0, oh+2], [0, oh-ov-2]]);
                sphere(1, $fn=16);
            }
        }
        // camera pocket, with a 0.6 mm lead-in chamfer at the open back
        translate([-iw/2, wall, wall]) cube([iw, id + 1, ih]);
        translate([0, od + 0.01, wall + ih/2]) rotate([90,0,0])
            linear_extrude(0.6, scale=[iw/(iw+1.2), ih/(ih+1.2)]) square([iw+1.2, ih+1.2], center=true);
        // lens window: teardrop (pointed top keeps the overhang at 45 deg),
        // chamfered on the front face
        translate([lens_off_x, 0, oh/2 + lens_off_z]) rotate([-90,0,0]) {
            translate([0,0,-0.5]) linear_extrude(wall + 1) lens_teardrop(lens_d + 1.0);
            translate([0,0,-0.01]) linear_extrude(0.81, scale=(lens_d+1.0)/(lens_d+2.6))
                lens_teardrop(lens_d + 2.6);
        }
        // slits that free a snap tongue at the back of each side wall
        for (sx=[-1,1]) for (sz=[-1,1])
            translate([sx > 0 ? iw/2 - 0.01 : -ow/2 - 1, od - tongue_l, wall + ih/2 + sz*(tongue_h/2 + slit_w/2) - slit_w/2])
                cube([wall + 1.01, tongue_l + 1, slit_w]);
        translate(bc) sphere(d=ball_d + 0.2);
        translate(bc) socket_mouth();
        for (s=[-1,1]) translate([s*sock_bx, bc[1], 0]) {
            translate([0,0,oh + 1]) cylinder(d=m3_pilot, h=sock_low + 1);
            translate([0,0,top]) hole_chamfer(m3_pilot);
        }
    }
    // Snap lips on the tips of the side tongues. They are vertical prisms, so
    // every face prints as a wall (no overhang). The camera pushes in from the
    // back, the ramps spread the tongues, and the square catch faces close
    // behind the camera's back edge on the left and right.
    y0 = wall + cam_d + fit;                 // camera back face when seated
    for (sx=[-1,1]) translate([sx*iw/2, 0, wall + ih/2 - (tongue_h - 2)/2])
        mirror([sx > 0 ? 1 : 0, 0, 0]) linear_extrude(tongue_h - 2)
            polygon([[-0.1, y0], [lip_d, y0], [lip_d, y0 + 0.6], [-0.1, y0 + 1.6]]);
}
// Lens window outline. 2D -Y is "up" in the cradle (rotate([-90,0,0]) maps it).
//  "circle"   : nominal round hole
//  "flat"     : teardrop cut flat at the circle's top, so the hole is no
//               taller than nominal; the flat is a short bridge
//  "teardrop" : full point, 45 deg all the way up (adds 0.41 x radius height)
module lens_teardrop(d) {
    if (lens_shape == "circle") circle(d=d, $fn=64);
    else intersection() {
        hull() {
            circle(d=d, $fn=64);
            translate([0, -d/2*sqrt(2)]) square(0.01, center=true);
        }
        if (lens_shape == "flat") translate([-d, -d/2]) square([2*d, 2*d]);
        else square(4*d, center=true);
    }
}

// CAP — modelled directly in print orientation: screw-head face on the bed,
// split face on top with the cup open upward (prints as a bowl, no sagging dome).
// Equivalent to the lower half mirrored: ball centre sits sock_gap above the top.
cap_H = sock_hh - sock_gap;
module cap_print() {
    difference() {
        rslab(cap_H, top=false) square([sock_W, sock_s], center=true);   // split face sharp
        translate([0,0,cap_H + sock_gap]) {
            sphere(d=ball_d + 0.2);
            rotate([0,0,180]) socket_mouth();          // mouth faces -Y in print frame
        }
        for (s=[-1,1]) translate([s*sock_bx, 0, 0]) {
            translate([0,0,-1]) cylinder(d=m3_clear, h=cap_H + 2);
            translate([0,0,-1]) cylinder(d=6, h=1 + 3);              // 3 mm head counterbore (bed side)
            translate([0,0,cap_H]) hole_chamfer(m3_clear);
        }
    }
}

/* ================= layout ================= */
if (PART == "base")   base();
if (PART == "arm")    arm();
if (PART == "stud")   stud();
if (PART == "cradle") cradle();
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
_iw = cam_w + 2*fit; _ih = cam_h + 2*fit; _id = cam_d + fit + lip_zone;
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

// reference camera (not printed): body seated in the cradle + lens ring
module camera_dummy() {
    translate([-cam_w/2, wall, wall + fit]) cube([cam_w, cam_d, cam_h]);
    translate([lens_off_x, wall + 0.01, _oh/2 + lens_off_z]) rotate([90,0,0]) cylinder(d=lens_d, h=wall + 5, $fn=48);
}
if (PART == "asm_camera") asm_cradle_tf() camera_dummy();
