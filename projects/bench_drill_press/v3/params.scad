// Bench drill press v3 — every dimension lives here. Units mm.
// Origin: spindle axis x=y=0, base top z=0, rods at +y. See ../design_v3.md.
include <fits.scad>

// --- variant = pose[_tool] ---
variant = "up";
variants = ["up","mid","down","up_555","down_555","up_iron","down_iron"];
pose = search("_", variant) == [] ? variant : chr([for (i = [0:search("_", variant)[0]-1]) ord(variant[i])]);
tool = search("_", variant) == [] ? "775" : chr([for (i = [search("_", variant)[0]+1:len(variant)-1]) ord(variant[i])]);
travel_len = 40;                            // plunge travel_len
plunge = pose == "up" ? 0 : pose == "mid" ? travel_len/2 : travel_len;

// --- printer & envelope ---
bed = [220, 220, 250];                  // Kobra 2 Neo
base_t = 15;                            // base plate thickness
base_x = 70;                            // base half-width
base_y = [-80, 100];                    // base front / rear edge
pad = [40, 40, 3];                      // work-pad pocket at the origin
clear_min = 40;                         // tip clearance, head up, tool highest

// --- rods ---
rod_x = [-35, 35];                      // rod axes
rod_y = 50;                             // rod plane
rod_d = 8;
rod_bore = fit_mid("H7", rod_d);
rod_socket = 12;                        // blind socket depth in the base

// --- head & feed geometry ---
head_h = 70;                            // head height
head_z0_up = 110;                       // head bottom (= 43 mm ring bottom) at plunge 0
head_z0 = head_z0_up - plunge;
pin_m = 1.5; pin_t = 14;                // main pinion module, teeth
pin_r = pin_m * pin_t / 2;              // 10.5 pitch radius
rack_pitch_y = 66;                      // rack pitch line (head rear); room for a 3 mm wall behind the rods
pinion_axis = [rack_pitch_y + pin_r, head_z0_up + 15];   // [y, z] shaft along x: 72.5, 125

// --- C-frame ---
wall = 3;                               // column wall
col = [-22, 22, rack_pitch_y + 3, base_y[1]];          // column x0, x1, y0 (front face), y1
arm_top = 215;                          // top-arm top face
arm_y0 = rod_y - 12;                    // top-arm front edge
arm_xh = 46;                            // top-arm half-width
arm_c = head_z0_up + head_h + 1;        // 45° arm underside starts here at the column face
shaft_d = 12;                           // printed shaft journal
shaft_bore = fit_mid("H9", shaft_d);
m3_clear = 3.4; m3_insert = [4.0, 5.0]; // UNVERIFIED insert size
m5_clear = 5.5; m5_insert = [6.4, 8.0];

// derived
rod_top = arm_top;                      // rods end flush with the arm top
rod_len = rod_top + rod_socket;         // cut length
function frame_h() = arm_top + base_t;
assert(frame_h() <= bed[2], str("frame height ", frame_h()));
assert(rod_len <= 250, str("rod length ", rod_len));
assert(2 * base_x <= 150 && base_y[1] - base_y[0] <= 190, "base footprint");
assert(col[0] > rod_x[0] + rod_d/2 + 3 && col[1] < rod_x[1] - rod_d/2 - 3, "column clear of rods");

// --- frame detail ---
boss_r = 9;                             // top-arm rod boss radius
boss_z0 = arm_top - 10;                 // boss underside (45° hull to the column top)
pin_w = 10;                             // pinion face width (window = pin_w + 4)
slider_w = 12;                          // spring-slider width (x)
spr_m = 1; spr_t = 10;                  // spring pinion module, teeth
spr_r = spr_m * spr_t / 2;              // 5 pitch radius
slider_back = pinion_axis[0] + spr_r + 1.25 * spr_m + 7;   // slider rear face (body 7 behind the tooth root)
lug = [5, 6, 4];                        // depth-stop lug (x, y, z) on the column's -x face
assert(col[1] - col[0] - 2*wall - 6 >= (pin_t + 2) * pin_m + 1, "gear pair must pass the rear access window");

// --- head (Task 2) ---
pa = 30;                                // pressure angle: 30° so the vertical rack prints like a thread
body_x = 44;                            // head body half-width
body_y0 = 20;                           // head body front face
rack_root_y = rack_pitch_y - 1.25 * pin_m;
slot_hw = [6, 11];                      // rod slot half-size (x, y) around each rod
seat_h = 12;                            // seat / gib contact height
seat_z = [7, 63];                       // contact centres above the head bottom (spacing 56)
seat_side = [+1, -1];                   // rigid seat side per zone [bottom, top]: +1 behind the rods, -1 in front
gib_L = 25; gib_t = 2; gib_b = 10;      // flexure blade length (root to contact), thickness, width
gib_preload = 3.5;                      // N per gib
E_pla = 3000;                           // MPa
gib_k = E_pla * gib_b * pow(gib_t, 3) / (4 * pow(gib_L, 3));   // N/mm (cantilever, end load)
gib_gap = gib_preload / gib_k;          // interference with the rod as printed (sets the preload)
function gib_stress() = 6 * gib_preload * gib_L / (gib_b * gib_t * gib_t);   // MPa
ring_d = 43;                            // Euro collar
ring_bore = fit_mid("H9", ring_d);
ring_h = 30; ring_wall = 5;
rack_teeth = 13;
rack_z0 = 4.5;                          // first rack tooth above the head bottom
head_cg_y = 15;                         // UNVERIFIED head + tool centre of gravity (mostly the motor at y 0)
head_mass = 0.55;                       // UNVERIFIED kg
// moment that tips the head, N·mm, + = top rearward (loads the rigid seats). Rack force down = work - weight.
function tip_moment(F_work) = (F_work - head_mass * 9.81) * rack_pitch_y + head_mass * 9.81 * head_cg_y;   // work reaction acts at y = 0
assert(gib_stress() <= 15, str("gib stress ", gib_stress(), " MPa"));
assert(seat_side == [+1, -1], "rigid seats must sit where the feed tips the head (top front, bottom rear)");
assert(seat_z[1] - seat_z[0] >= 56, "seat spacing");
assert(ring_d == 43, "Euro collar");
for (F = [2, 5, 50]) assert(tip_moment(F) >= -2 * gib_preload * (seat_z[1] - seat_z[0]), str("feed ", F, " N lifts a gib"));
