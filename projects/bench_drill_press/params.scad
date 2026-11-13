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
rod_len = 250;                          // cut from one 500 mm rod
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

// derived
rod_x = [-rod_pitch/2, rod_pitch/2];    // rod axis x positions
rod_top_z = rod_len - rod_socket_depth; // rod top above base top

// base plan position
base_y0 = -88;                          // front edge y
base_y1 = base_y0 + base_d;             // rear edge y (= 72)
spine_y = [63, 71];                     // spine rib y range (behind sleeves)
spine_w = 30;                           // spine rib width (x)
spine_insert_x = [-8, 8];               // spine foot insert x positions
clamp_screw_dx = 10;                    // clamp screw offset outboard of rod axis
clamp_cb = [6.0, 8];                    // M3 counterbore dia, depth from rear face
