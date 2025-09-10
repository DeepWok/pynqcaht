use <roundedcube.scad>
include <vars.scad>

margin = 0.1;
t = wall_thickness + top_tab_thickness;

module top() {

	module tab() {
		translate([mid_dist[0] - wall_thickness/2, -inner_dim[1]/4, top_tab_thickness/2]) cube([
			wall_thickness*2,
			top_tab_width - 2*margin,
			top_tab_thickness - 2*margin,
		], center=true);
	}

	difference() {
		translate([0, 0, t/2]) cube([
			inner_dim[0] - 2*margin,
			inner_dim[1] - 2*margin,
			t,
		], center=true);
		translate([0, 0, top_tab_thickness/2]) cube([
			inner_dim[0] - 2*wall_thickness - epsilon,
			inner_dim[1] + epsilon,
			top_tab_thickness + epsilon,
		], center=true);

		translate([0, 0, t - text_height + epsilon])
		linear_extrude(text_height)
		text(
			"PYNQ Chat",
			font="Liberation Sans:Bold",
			size=10, halign="center", valign="center",
			spacing = 1
		);
	}

	tab();
	mirror([1, 0, 0]) tab();
	mirror([0, 1, 0]) tab();
	mirror([1, 0, 0]) mirror([0, 1, 0]) tab();

}

translate([0, 0, t]) rotate([180, 0, 0]) top();
