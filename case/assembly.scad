use <board.scad>
use <bottom.scad>
use <top.scad>
include <vars.scad>

color([1, 0, 0.7]) bottom();
color([0, 0.7, 1]) translate([0, 0, board_sit_height]) board();
color([1, 0.7, 0]) translate([0, 0, inner_dim[2] - wall_thickness - top_tab_thickness]) top();
