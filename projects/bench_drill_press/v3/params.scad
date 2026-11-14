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
head_z0_up = 118;                       // head bottom (= 43 mm ring bottom) at plunge 0; the iron needs 75 mm ring-to-tip
head_z0 = head_z0_up - plunge;
pin_m = 1.5; pin_t = 14;                // main pinion module, teeth
pin_r = pin_m * pin_t / 2;              // 10.5 pitch radius
rack_pitch_y = 66;                      // rack pitch line (head rear); room for a 3 mm wall behind the rods
pinion_axis = [rack_pitch_y + pin_r, head_z0_up + 15];   // [y, z] shaft along x: 72.5, 125

// --- C-frame ---
wall = 3;                               // column wall
col = [-24, 24, rack_pitch_y + 3, base_y[1]];          // column x0, x1, y0 (front face), y1
arm_top = 233;                          // top-arm top face (frame 248 ≤ 250)
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
slider_x = 12;                          // spring pinion + slider centre (x); main pinion sits at x = 0
slider_w = 10;                          // spring-slider width (x), centred on slider_x
spr_m = 1; spr_t = 8;                   // spring pinion cut into the shaft: tips Ø10 pass the Ø12 bores
spr_r = spr_m * spr_t / 2;              // 4 pitch radius
spr_b = 12;                             // spring pinion face width
slider_back = pinion_axis[0] + spr_r + 1.25 * spr_m + 7;   // slider rear face (body 7 behind the tooth root)
lug_pin_d = 7;                          // depth-stop pin (along x) the ring's tooth hits
lug_off = [11.3, 11.3];                 // pin centre offset from the shaft axis (y behind, z above): R 16
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

// --- drive (Task 3) ---
shaft_hex = 10;                         // hex across flats (gear pair + handle hub), passes the Ø12 bores
shaft_x = [-58, 62];                    // shaft ends
collar = [16, 2];                       // retaining collar outside the +x wall (Ø, thickness)
hub_x = [50, 62];                       // handle hub on the +x hex end (clear of head x ±44)
spoke_r = 60;                           // handle spoke radius
stop_x = [-56, -48];                    // depth-stop ring, outboard of the head (its tooth sweeps a full circle)
stop_tooth_r = 19;                      // ring tooth radius (reaches past the pin centre)
stop_ring_r = 11;                       // ring body radius (M3 clamp pilot has 1 mm wall each side)
mu = 0.3;                               // PLA on chrome rod
n_contacts_normal = 4 + 2 + 2 * sqrt(2);// gib + pad + V-flank normals, in units of gib_preload
friction = mu * gib_preload * n_contacts_normal;                 // N
ks_L0 = 75; ks_k = 2.0; ks_T0 = 10; ks_od = 12; ks_max_ext = 0.5;   // UNVERIFIED kickstand spring
ks_need = 1.25 * (head_mass * 9.81 + friction) * pin_r / spr_r;     // N at the top
ks_x_top = max(0.5, (ks_need - ks_T0) / ks_k);                    // preload stretch at the top
function shaft_rot(p) = p / pin_r * 180 / PI;                     // deg about +x, head down -> +
function slider_dz(p) = p * spr_r / pin_r;                        // slider rises as the head drops
slider_h = 34;                          // fits under the column's pyramid roof at full plunge
slider_z0_up = pinion_axis[1] - 25;                               // slider bottom at the top pose (rests on its ledge)
ks_anchor_z = slider_z0_up - (ks_L0 + ks_x_top);
function ks_ext(p) = ks_x_top + slider_dz(p);
function ks_force(p) = ks_T0 + ks_k * ks_ext(p);
function ret_torque(p) = ks_force(p) * spr_r;                     // N·mm lifting the head (+)
function gear_stress(F, m, b) = F / (b * m * 0.3);                // Lewis, Y ≈ 0.3
rack_len = rack_teeth * PI * pin_m;
n_printed = 10; n_screws = 8;                                     // design_v3 §2 budget
assert(ret_torque(0) >= 1.25 * (head_mass * 9.81 + friction) * pin_r - 0.01, str("return torque ", ret_torque(0)));
assert(ret_torque(0) > 0 && ret_torque(travel_len) > 0, "spring must lift the head at both ends");
assert(ks_ext(travel_len) <= ks_max_ext * ks_L0, str("kickstand over-stretched: ", ks_ext(travel_len)));
assert(ks_anchor_z > wall, "spring anchor above the column floor");
assert(rack_len >= travel_len + 4 + pin_r, str("rack too short: ", rack_len));
assert(gear_stress(ks_force(travel_len), spr_m, spr_b) <= 25, str("spring pinion tooth stress ", gear_stress(ks_force(travel_len), spr_m, spr_b)));
assert(gear_stress(ks_force(travel_len) * spr_r / pin_r + 50, pin_m, pin_w) <= 25, "main pinion tooth stress");
assert(2 * PI * pin_r >= travel_len, "stop ring one turn covers the travel");
assert(n_printed <= 10 && n_screws <= 8, "part / screw budget");
spring_y = slider_back - 0.5;           // kickstand spring axis y (hooks the slider's rear bar)
ledge = [slider_x + slider_w/2, slider_x + slider_w/2 + 2.7, pinion_axis[0] + spr_r + 1.25 * spr_m, pinion_axis[0] + spr_r + 1.25 * spr_m + 1.6];   // tab/ledge x0,x1,y0,y1
// tooth phases: BOSL2 puts a tooth on local +y (= world +y after the rotate onto x); turn so a tooth sits in the rack gap at the mesh
function _gap_z(z0, p) = z0 + (round((pinion_axis[1] - z0) / p - 0.5) + 0.5) * p;
gear_phase = -(_gap_z(head_z0_up + rack_z0, PI * pin_m) - pinion_axis[1]) / pin_r * 180 / PI;
spr_phase = (_gap_z(slider_z0_up + 2, PI * spr_m) - pinion_axis[1]) / spr_r * 180 / PI;
assert(spr_m * (spr_t + 2) < shaft_d, "integral spring pinion must pass the shaft bores");
assert(pin_m * (pin_t - 2.5) > shaft_hex / cos(30) + 3, "main pinion root clears its hex bore");

// --- tools in the 43 mm ring (Task 4) ---
m775_d = 42; m775_len = 67; m775_boss = [17.5, 4.5];   // UNVERIFIED
m555_d = 35.8; m555_len = 57; m555_boss = [13, 3];      // UNVERIFIED
chuck_d = 22; chuck_len = 40; bit_stickout = 20; shaft_gap = 8;   // UNVERIFIED
iron_d = 22; iron_hot_len = 60; iron_barrel_d = 8;      // UNVERIFIED pen iron
iron_air_gap = 15;                                      // PLA only: min air from any part to the hot zone
ring_slit = 4;                                          // ring split: closes enough to grip the 775 (Ø42) directly
sleeve_wall_min = 2;
// D = ring bottom to tool tip with the tool at s = 0 (motor face / iron grip datum at the ring bottom)
tool_D = tool == "iron" ? iron_hot_len + iron_air_gap : shaft_gap + chuck_len + bit_stickout;
s_up = head_z0_up - tool_D - clear_min;                 // how far the tool sits below the ring at the "up" (highest) setting
s_dn = head_z0_up - travel_len - tool_D + 1.5;          // lowest setting: tip 1.5 mm into the work pad
tool_s = pose == "up" ? s_up : pose == "mid" ? (s_up + s_dn)/2 : s_dn;
function tip_z(p, s) = head_z0_up - p - s - tool_D;
clamp_force = 1000 * 0.5;                               // N: M5 preload x ring compliance factor
assert(tip_z(0, s_up) >= clear_min, str("clearance ", tip_z(0, s_up)));
assert(tip_z(travel_len, s_dn) <= 0 && tip_z(travel_len, s_dn) >= -pad[2], str("reach ", tip_z(travel_len, s_dn)));
assert(s_up >= 0, "tool must sit at or below the ring bottom (iron: keeps the 15 mm air gap)");
assert(mu * clamp_force >= 150, "ring clamp holds 3x a 50 N thrust");
assert(PI * (ring_bore - m775_d) <= ring_slit, "ring split must close enough to grip the 775 without a shim");
assert((ring_d - m555_d)/2 >= sleeve_wall_min && (ring_d - iron_d)/2 >= sleeve_wall_min, "sleeve walls");
