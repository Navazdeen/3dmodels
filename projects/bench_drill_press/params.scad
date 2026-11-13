// Bench drill press — every dimension lives here. Units mm.
// Origin: spindle axis x=y=0, base top surface z=0, rods at +y.
include <fits.scad>

// --- pose (variant) ---
variant = "up";                         // up | mid | down
variants = ["up","mid","down"];
plunge = variant=="up" ? 0 : variant=="mid" ? 20 : 40;   // carriage drop from top, mm

// --- envelope ---
bed = [220,220,250];                    // Kobra 2 Neo build volume
base_w = 140;                           // base width (x)
base_d = 160;                           // base depth (y)
base_t = 20;                            // base plate thickness
travel_len = 40;                        // plunge travel
clear_min = 40;                         // min base-to-tip clearance, head up, holder high
h_max = 280;                            // compact overall height limit

// --- rods (hw) ---
rod_d = 8;                              // smooth rod diameter
rod_pitch = 70;                         // x distance between rod axes
rod_y = 50;                             // rod plane distance behind spindle axis
rod_socket_depth = 18;                  // rod depth into base
rod_bore = fit_mid("H7", rod_d);        // rod socket bore

// --- fasteners (inserts UNVERIFIED until owner confirms sizes) ---
m3_clear = 3.4;                         // M3 clearance (ISO 273 medium)
m3_insert = [4.0, 5.0];                 // UNVERIFIED insert hole dia, depth
m5_clear = 5.5;                         // M5 clearance
m5_insert = [6.4, 8.0];                 // UNVERIFIED insert hole dia, depth
clamp_slot = 1.2;                       // split-clamp slot width

// --- base features ---
pad = [40,40,3];                        // replaceable work pad pocket (x,y,depth)
bench_hole = 4.5;                       // bench screw holes
corner_r = 6;                           // plan-view corner radius
edge_ch = 1;                            // edge chamfer

rod_len_max = 250;                      // half of one 500 mm rod

// --- carriage (positions needed by the frame) ---
carriage_h = 72;                        // carriage height (sleeve pitch 48)
carriage_z0_up = 100;                   // carriage bottom at plunge 0 (set by tool drop, Task 5)
carriage_z0 = carriage_z0_up - plunge;  // carriage bottom at this pose
carriage_x = rod_pitch/2 + 15/2 + 3.5;  // carriage half-width (rod + sleeve + wall) = 46
pin_y = 32;                             // lever link pin y on carriage side
pin_dz = carriage_h - 12;               // link pin height above carriage bottom

// --- top bridge ---
bridge_gap = 8;                         // carriage top (up) to bridge underside
bridge_t = 20;                          // bridge thickness
bridge_w = 110;                         // bridge width (x)
bridge_y0 = rod_y - 12;                 // bridge front edge

// --- lever pivot (ear on bridge, right side) ---
lever_r = 40;                           // pin radius from pivot (slot horizontal at mid plunge)
ear_x = [carriage_x + 2, carriage_x + 12];   // pivot ear x range
lever_x = [ear_x[1] + 0.5, ear_x[1] + 8.5]; // lever plate x range
pivot_d = fit_mid("H9", 8);             // M8 pivot bore

// --- spine (behind base & bridge rear faces) ---
spine_w = 30;                           // spine width (x)
spine_t = 10;                           // spine thickness (y)
spine_screw_x = [-8, 8];                // M3 screws into rear-face inserts
spine_screw_dz = 10;                    // screw height below base top / below bridge top

// derived
rod_x = [-rod_pitch/2, rod_pitch/2];             // rod axis x positions
bridge_z0 = carriage_z0_up + carriage_h + bridge_gap;   // bridge underside
bridge_top = bridge_z0 + bridge_t;
rod_top_z = bridge_z0 + rod_socket_depth;        // rod top (blind socket in bridge)
rod_len = rod_top_z + rod_socket_depth;          // cut length
pivot_pos = [ear_x[0], pin_y + lever_r, carriage_z0_up - travel_len/2 + pin_dz];  // axis along +x
overall_h = bridge_top + base_t;
assert(rod_len <= rod_len_max, str("rod_len ", rod_len, " > ", rod_len_max));
assert(overall_h <= h_max, str("overall_h ", overall_h));
assert(clamp_slot >= 1);

// base plan position
base_y0 = -88;                          // front edge y
base_y1 = base_y0 + base_d;             // rear edge y (= 72)
clamp_screw_dx = 10;                    // clamp screw offset outboard of rod axis
clamp_cb = [6.0, 8];                    // M3 counterbore dia, depth from rear face
