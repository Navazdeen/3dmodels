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
base_y = [-76, 112];                    // base front / rear edge (rear: collar round column + cover)
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
col = [-24, 24, rack_pitch_y + 3, 100];          // column x0, x1, y0 (front face), y1
arm_top = 233;                          // top-arm top face (frame 248 ≤ 250)
arm_y0 = rod_y - 12;                    // top-arm front edge
arm_xh = 46;                            // top-arm half-width
arm_c = head_z0_up + head_h + 1;        // 45° arm underside starts here at the column face
shaft_d = 14.5;                         // printed shaft: -x journal, stop section, spacers (spring pinion tips Ø14 pass)
journal_mx = shaft_d;
shaft_bore = fit_mid("H9", 6) + 0.05;   // -x boss: the fixed M6 axle (+0.05 facet clearance)
bore_px = fit_mid("H9", 11.6) + 0.05;   // +x boss: the handle's Ø11.6 drive sleeve
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
slider_x = -12;                         // spring pinion + slider centre (x), -x of the main pinion: handle torque bypasses its core
slider_w = 10;                          // spring-slider width (x), centred on slider_x
spr_m = 1; spr_t = 12;                  // spring pinion cut into the shaft (-x of the main pinion): core Ø9.5
spr_r = spr_m * spr_t / 2;              // 4 pitch radius
spr_b = 12;                             // spring pinion face width
slider_back = pinion_axis[0] + spr_r + 1.25 * spr_m + 7;   // slider rear face (body 7 behind the tooth root)
lug_pin_d = 9;                          // depth-stop pin (along x): ~14 MPa at 30 N on the handle
lug_off = [13.1, 13.1];                 // pin centre offset from the shaft axis (y behind, z above): R 18.5
assert(col[1] - col[0] - 2*wall - 6 >= (pin_t + 2) * pin_m + 1, "gear pair must pass the rear access window");

// --- head (Task 2) ---
pa = 30;                                // pressure angle: 30° so the vertical rack prints like a thread
body_x = 44;                            // head body half-width
body_y0 = 28;                           // head body front face (behind the free-flexing ring)
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
shaft_hex = 10;                         // main-pinion hex (across flats)
hub_hex = 8;                            // handle hex (across flats), passes the main pinion's hex
shaft_x = [-58, 62];                    // shaft ends
collar = [18.5, 2];                     // collar outside the -x wall (shaft goes in from -x; the handle sleeve holds the other way)
hub_x = [50, 62];                       // handle hub on the +x hex end (clear of head x ±44)
spoke_r = 60;                           // handle spoke radius
stop_x = [-58, -44];                    // depth-stop ring (14 wide, 2 clamp screws), outboard of the head
stop_tooth_r = 21;                      // ring tooth radius (reaches past the pin centre)
stop_ring_r = 12.5;                     // ring body radius
mu = 0.3;                               // PLA on chrome rod
n_contacts_normal = 4 + 2 + 2 * sqrt(2);// gib + pad + V-flank normals, in units of gib_preload
friction = mu * gib_preload * n_contacts_normal;                 // N
ks_L0 = 75; ks_k = 2.0; ks_T0 = 10; ks_od = 12; ks_max_ext = 0.5;   // UNVERIFIED kickstand spring
ks_need = 1.25 * (head_mass * 9.81 + friction) * pin_r / spr_r;     // N at the top
ks_x_top = max(0.5, (ks_need - ks_T0) / ks_k);                    // preload stretch at the top
function shaft_rot(p) = p / pin_r * 180 / PI;                     // deg about +x, head down -> +
function slider_dz(p) = p * spr_r / pin_r;                        // slider rises as the head drops
slider_h = 42;                          // rack covers the mesh over 23 mm of slider travel
slider_z0_up = pinion_axis[1] - 35;                               // slider bottom at the top pose; hook stays clear of the spring pinion at full plunge
tab_dz = 8;                             // top-stop tab sits above the hook hole
ks_anchor_z = slider_z0_up + 4 - 2 - (ks_L0 + ks_x_top);          // spring top hooks the slider's cross-hole
function ks_ext(p) = ks_x_top + slider_dz(p);
function ks_force(p) = ks_T0 + ks_k * ks_ext(p);
function ret_torque(p) = ks_force(p) * spr_r;                     // N·mm lifting the head (+)
function gear_stress(F, m, b) = F / (b * m * 0.3);                // Lewis, Y ≈ 0.3
rack_len = rack_teeth * PI * pin_m;
// v3.1 BOM: [item, qty, screws per item]. README's hardware table is this list.
printed_parts = ["base", "column", "rear_cover", "top_arm", "head", "gear_cluster", "spring_slider", "handle_hub", "depth_collar", "sleeve_555", "sleeve_iron"];
hw_bom = [["M5 x 16 socket + M5 nut (frame joints: 4 base, 2 arm)", 6, 1], ["M5 x 25 socket + M5 nut (depth collar)", 1, 1],
          ["M5 x 20 socket + M5 heat-set insert (43 mm ring clamp)", 1, 1], ["M3 x 6 grub + M3 heat-set insert (rod retention)", 2, 1],
          ["M3 x 16 thread-forming (bottom gib adjusters)", 2, 1], ["M3 x 10 thread-forming (top gib adjusters)", 2, 1],
          ["M6 x 100 part-threaded bolt + 2 M6 nuts (fixed axle)", 1, 1]];
n_printed = len(printed_parts);
n_screws = [for (h = hw_bom) 1] * [for (h = hw_bom) h[1] * h[2]];
assert(ret_torque(0) >= 1.25 * (head_mass * 9.81 + friction) * pin_r - 0.01, str("return torque ", ret_torque(0)));
assert(ret_torque(0) > 0 && ret_torque(travel_len) > 0, "spring must lift the head at both ends");
assert(ks_ext(travel_len) <= ks_max_ext * ks_L0, str("kickstand over-stretched: ", ks_ext(travel_len)));
assert(ks_anchor_z > wall, "spring anchor above the column floor");
assert(rack_len >= travel_len + 4 + pin_r, str("rack too short: ", rack_len));
assert(gear_stress(ks_force(travel_len), spr_m, spr_b) <= 25, str("spring pinion tooth stress ", gear_stress(ks_force(travel_len), spr_m, spr_b)));
assert(gear_stress(ks_force(travel_len) * spr_r / pin_r + 50, pin_m, pin_w) <= 25, "main pinion tooth stress");
assert(n_printed <= 11 && n_screws <= 20, str("part / screw budget: ", n_printed, " printed, ", n_screws, " screws"));
assert(n_screws == 15, str("BOM screw count changed: ", n_screws, " (update README)"));
spring_y = (pinion_axis[0] + spr_r + 1.25 * spr_m + slider_back) / 2;   // spring axis y: under the slider's hook hole
ledge = [slider_x - slider_w/2 - 3, slider_x - slider_w/2, pinion_axis[0] + spr_r + 1.25 * spr_m, pinion_axis[0] + spr_r + 1.25 * spr_m + 5];   // tab x0,x1,y0,y1 (outboard -x side, 3 x 5)
// tooth phases: BOSL2 puts a tooth on local +y (= world +y after the rotate onto x); turn so a tooth sits in the rack gap at the mesh
function _gap_z(z0, p) = z0 + (round((pinion_axis[1] - z0) / p - 0.5) + 0.5) * p;
gear_phase = -(_gap_z(head_z0_up + rack_z0, PI * pin_m) - pinion_axis[1]) / pin_r * 180 / PI;
spr_phase = (_gap_z(slider_z0_up + 2, PI * spr_m) - pinion_axis[1]) / spr_r * 180 / PI;
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

// ===== final-review fixes (2026-11-14): values below are the CURRENT (broken) design; each assert must fail first =====
gib_eff_L = gib_L;                              // root block now sits beyond gib_L (head.scad gib())
spr_root_d = spr_m * (spr_t - 2.5);             // spring-pinion core
T_stop = 30 * spoke_r;                          // N·mm: a hand leaning on the handle at the depth stop
journal_px = 9.7;                               // +x journal Ø: passes the main pinion's hex (shaft goes in from -x)
anchor_d = 8; anchor_supported = true;          // diamond bar across both column walls
adj_front_y0 = body_y0 - 1;                     // front gib adjuster pilots start outside the body front face
slider_hook_d = 4;                              // cross-hole (along x) for the spring hook in the slider
tick_dir = 1;                                   // +1: tick i aligns with the pin when the stop is set to depth i
stop_screws = 2; stop_r_shaft = journal_mx/2;   // clamp screws, shaft radius under the stop ring
ring_neck_hw = 6;                               // ring joins the body only through a rear neck this half-wide
ring_free_arc = 360 - 2 * atan(ring_neck_hw / (ring_d/2 + ring_wall));
tab_xy = [ledge[1] - ledge[0], ledge[3] - ledge[2]];   // top-stop tab footprint
function torsion(T, d) = 16 * T / (PI * pow(d, 3));
function cantilever(F, a, d) = 32 * F * a / (PI * pow(d, 3));
function ring_arm_stress() = let(L = (ring_d/2 + ring_wall/2) * (ring_free_arc/2) * PI / 180)
  3 * E_pla * ring_wall * (PI * (ring_bore - m775_d) / 2) / (2 * L * L);
assert(gib_eff_L == gib_L, str("gib bending length is ", gib_eff_L, ", stiffness assumes ", gib_L));
anchor_a = slider_x - (col[0] + wall); anchor_b = (col[1] - wall) - slider_x;
anchor_M = ks_force(travel_len) * anchor_a * anchor_b / (anchor_a + anchor_b);   // simply supported, N·mm
assert(anchor_supported && 32 * anchor_M / (PI * pow(anchor_d, 3)) <= 15, str("spring anchor stress ", 32 * anchor_M / (PI * pow(anchor_d, 3))));
assert(adj_front_y0 <= body_y0, "front gib adjusters unreachable");
assert(slider_hook_d >= 3.5, "spring has nothing to hook on the slider");
assert(ring_arm_stress() <= 10, str("ring arm stress ", ring_arm_stress(), " MPa to grip the 775"));
assert(tab_xy[0] >= 3 && tab_xy[1] >= 5, "top-stop tab too small");

// ===== print-rule fixes (3d-print-designer: fillet inside corners; PLA elephant-foot chamfer 0.3-0.4) =====
fillet_r = 1.5;                         // inside-corner fillet at loaded roots
ef = 0.4;                               // elephant-foot chamfer on bed-side fitting edges
assert(fillet_r >= 1, "inside corners need >= 1 mm fillets (PLA is notch-sensitive)");
assert(ef >= 0.3 && ef <= 0.5, "elephant-foot chamfer on bed-side fitting edges (PLA 0.3-0.4 mm)");

// ===== v3.1 frame split (plan_v3_1 Task 1) =====
arm_t = 20;                             // top-arm plate thickness
col_top = arm_top - arm_t;              // column top = arm underside
key_d = 3; key_c = 0.2;                 // column ends sit key_d deep in pockets (clearance key_c) in the base and arm
col_len = col_top + 2 * key_d;          // printed length of the column (lying on its side)
cjoint = [6, 15];                       // base collar / arm skirt round the column ends: wall, height
bolt_y = [col[2] + 8, col[3] - 5.5];     // side-bolt y positions: rear one behind the spring anchor post (its shank used to run through it)
cover_t = 3;                            // rear cover thickness (closes the U-channel)
m5_nut = [8.0, 4.7];                    // M5 nut across flats, thickness (ISO 4032)
m5_head = [8.5, 5];                     // M5 socket head Ø, height (ISO 4762)
joint_l = 16;                           // M5 joint screw length (hardware.py pick M5 --grip 9.2 --nut)
nut_pocket = [m5_nut[0] + 0.2, m5_nut[1] + 0.1];   // captive pocket inside the column top: AF, depth
col_print_h = col[1] - col[0];          // column lying on its -x side: print height = its width
assert(col_len <= bed[0] - 1, str("column ", col_len, " mm long: must fit the bed lying down"));
assert(base_t <= 120 && col_print_h <= 120 && arm_t <= 120 && cover_t <= 120, "print heights");
assert(key_c <= 0.2, "joint key clearance");
assert(cjoint[0] >= 5 && cjoint[1] >= 12, "collar/skirt must hold an M5 nut-and-bolt joint");
ledge_x1 = min(ledge[1] - 0.3, slider_x - ks_od/2 - 0.5);   // ledge stops short of the spring envelope

// ===== v3.1 fixed M6 axle (plan_v3_1 Task 2) =====
axle_d = 6; axle_len = 100;             // M6 x 100 partly threaded (owner stock), fixed: head at +x, nut + jam nut at -x
boss_len = 5.7;                         // bearing length of each column boss (wall + inward boss; cluster/sleeve 0.3 clear)
sleeve_od = 11.6; sleeve_id = axle_d + 0.3;   // handle's round drive sleeve (through the +x boss)
hex_af = 9.8; hex_len = 8;              // handle-to-cluster drive: hex on the sleeve end (passes the +x bore), socket in the cluster
hex_c = 0.3;                            // socket clearance on the across-flats
F_bear = 150;                           // N: worst radial load on one boss (rack + spring)
function bearing_p() = F_bear / (axle_d * boss_len);
function tube_shear(T, D, d) = 16 * T * D / (PI * (pow(D, 4) - pow(d, 4)));
assert(bearing_p() <= 5, str("bearing pressure on the M6 ", bearing_p(), " MPa"));
assert(tube_shear(T_stop, sleeve_od, sleeve_id) <= 8, "handle sleeve torsion");
assert(axle_len >= 100, "axle length");
assert(tube_shear(ks_force(travel_len) * spr_r, spr_root_d, sleeve_id) <= 8, "cluster core between the pinions (spring torque)");
assert(pin_m * (pin_t - 2.5) / 2 - (hex_af + hex_c) / cos(30) / 2 >= 2, "hex socket corners clear the main pinion root by 2 mm");

// ===== v3.1 depth collar + scale (plan_v3_1 Task 3) =====
// Split C-collar on the left rod: slit to the front, M5 across the front ears, thin back acts as the hinge.
collar_h = 16; collar_d = 18;           // body Ø (5 mm wall round the rod)
collar_bore = rod_d + 0.3;              // slides on when loose; the M5 closes the slit
collar_slit = 2; collar_bolt_dy = 15;   // M5 axis in front of the rod axis
collar_ear = [16, collar_bolt_dy + m5_head[0]/2 + 1.5];   // ears: x width, reach in front of the rod axis (-y); 1.5 mm skin past the head
pla_creep = 12;                         // MPa sustained (3d-print-designer material-pla)
clamp_n = pla_creep * PI/4 * (m5_head[0]*m5_head[0] - m5_clear*m5_clear);   // N preload PLA keeps under the head (~395)
collar_lever = (collar_bolt_dy + collar_d/2) / (collar_d/2);
assert(collar_ear[1] - collar_bolt_dy - m5_clear/2 >= 1.2, "collar ear skin in front of the M5");   // hinge at the back: screw arm / rod-centre arm
collar_hold = mu * clamp_n * 2 * collar_lever;                // N, friction on both jaws
collar_bore_p = clamp_n * collar_lever / (rod_d * collar_h);   // MPa, projected jaw pressure on the rod
rack_force = 30 * spoke_r / pin_r;      // N at the rack, 30 N on a 60 mm spoke
function collar_z(depth) = head_z0_up - depth;   // collar top: the head bottom lands here at that plunge
// pointer fin on the head's -x back corner, reading a scale on the column's -x face
ptr_dz = 68;                            // index edge above the head bottom: whole range clears the axle nuts (z <= 139)
ptr_x = [col[0] - 5, col[0] - 1];       // 1 mm off the scale face
ptr_y1 = col[2] + 4;                    // tip
scale_y = col[2] + 1.5;                 // ticks start 1.5 behind the column front edge (wall rule)
scale_range = [0, travel_len];
assert(collar_hold >= 3 * rack_force, str("depth collar holds ", collar_hold, " N < 3 x ", rack_force));
assert(collar_bore_p <= pla_creep, str("collar jaw pressure ", collar_bore_p, " MPa"));
assert(scale_range[0] <= 0 && scale_range[1] >= travel_len, "scale covers the full plunge");
assert(head_z0_up - travel_len + ptr_dz - 1.5 - (ptr_y1 - (pinion_axis[0] - 11.05/2)) >= pinion_axis[1] + 11.05/2 + 1, "pointer fin clears the axle nuts at full plunge");
assert(ptr_dz <= head_h, "pointer on the head");
assert(collar_z(travel_len) - collar_h > base_t, "collar above the base");

// column bending at the foot from the drilling reaction (spec: reported). Conservative: open U only, cover ignored.
function col_bend_stress(F) = let(b = col[1] - col[0], h = col[3] - col[2], t = wall,
    Af = b * t, Aw = 2 * t * (h - t), yf = t/2, yw = t + (h - t)/2, yc = (Af * yf + Aw * yw) / (Af + Aw),
    I = b * t*t*t / 12 + Af * pow(yc - yf, 2) + 2 * t * pow(h - t, 3) / 12 + Aw * pow(yw - yc, 2))
  F * (col[2] + yc) * max(yc, h - yc) / I;   // moment arm: tool axis (y 0) to the section centroid
assert(col_bend_stress(50) <= 10, str("column bending ", col_bend_stress(50), " MPa at 50 N"));

// assembly path: the rear cover drops in from above, so its slider-guide ribs (plan y >= slider_back + 0.3)
// must miss every inward feature above them in plan: the arm-joint nut blocks.
top_bolt_y = [bolt_y[0]];              // arm joint: front bolt only per side (a rear pocket would block the cover's ribs)
nut_block_y1 = top_bolt_y[0] + nut_pocket[0]/2 + 1.6;   // rear end of the captive-nut blocks inside the column top
assert(nut_block_y1 <= slider_back + 0.3 - 0.5, str("cover ribs hit the nut blocks while sliding in: block to y ", nut_block_y1, ", ribs from ", slider_back + 0.3));

// ===== final-review fix pass: tests =====
// R1 handle must pass the +x bore on the way in (only the final pose was clash-checked)
handle_in_r = hex_af / cos(30) / 2;     // widest point of the handle that goes through the bore (hex corners)
assert(handle_in_r <= bore_px/2 - 0.1, str("handle can't pass the +x bore: r ", handle_in_r, " vs bore r ", bore_px/2));
// R3 coupling stress at 30 N on the spoke. Hex: flats in bearing (along the layers) and the hollow hex in torsion
// (layer-plane shear, the one stress across layers). Hex torsion J ~ 0.1154 s^4 (Roark), minus the bore.
hex_torsion = T_stop * (hex_af/2) / (0.1154 * pow(hex_af, 4) - PI * pow(sleeve_id, 4) / 32);
hex_bearing = 2 * T_stop / (6 * (hex_af / sqrt(3) / 2) * hex_len * (hex_af / 2));   // load on the outer half of each flat
coupling_stress = max(hex_torsion, hex_bearing);
assert(coupling_stress <= 12, str("handle-to-cluster coupling ", coupling_stress, " MPa"));
// I4 collar hinge ligament (the lever needs it to carry (lever-1) x clamp in sustained tension)
collar_lig_stress = (collar_lever - 1) * clamp_n / ((collar_d - collar_bore)/2 * collar_h);
assert(collar_lig_stress <= 10, str("collar hinge ligament ", collar_lig_stress, " MPa (creep)"));
// I7 main pinion tip vs the pinion window edge in the front wall (bolt play up to 0.25 mm)
win_hh = 12.5;                          // pinion window half-height in the front wall
assert(win_hh >= sqrt(pow(pin_m * (pin_t + 2) / 2, 2) - pow(pinion_axis[0] - col[2] - wall, 2)) + 1, "pinion tip clears the window edge by 1 mm");

// C2 the spring slider needs a guide straight behind it at the mesh height (the 30° teeth push it back 18-45 N)
slider_rib = [slider_z0_up + slider_dz(travel_len) + 6, pinion_axis[1] + 12];   // z: above the spring's top hook at full plunge
assert(slider_rib[0] <= pinion_axis[1] - 6 && slider_rib[1] >= pinion_axis[1] + 6, "rear rib covers the spring-pinion mesh");
assert(slider_rib[0] >= slider_z0_up + slider_dz(travel_len) + 4 - slider_hook_d/2 + 1, "rear rib clears the spring top");
