// Sleeve bore test set. Notches on the rim: 1 = 7.9, 2 = 8.0 ... 6 = 8.4.
// Print, keep the bore that slides on the rod with no play,
// then set sleeve_bore in params.scad.
include <params.scad>
include <frame.scad>
include <carriage.scad>
bores = [7.9, 8.0, 8.1, 8.2, 8.3, 8.4];
assert(min(bores) <= 7.9 && max(bores) >= 8.4, "test set must span 7.9..8.4");
for (i = [0:len(bores)-1]) translate([i * 20, 0, 0]) sleeve_labelled(bores[i], i + 1);
