use <cutouts.scad>
use <roundedcube.scad>
include <vars.scad>

module bottom() {
	module cutout() {
		translate([0, 0, board_thickness+board_sit_height])
		rotate([90, 0, 0])
		linear_extrude(wall_thickness+epsilon, center=true)
		children();
	}

	module cutout_below() {
		translate([0, 0, board_sit_height])
		rotate([-90, 0, 0])
		linear_extrude(wall_thickness+epsilon, center=true)
		children();
	}

	module tab_cutout() {
		// top tab cutout
		translate([-mid_dist[0], inner_dim[1]/4, inner_dim[2] - top_tab_thickness/2 - wall_thickness])
			cube([
				wall_thickness + epsilon,
				top_tab_width,
				top_tab_thickness,
			], center=true);
	}

	difference() {
		// base hollow box
		difference() {
			translate([0, 0, inner_dim[2]/2 - wall_thickness/2 - epsilon])
			roundedcube([
				inner_dim[0] + 2*wall_thickness,
				inner_dim[1] + 2*wall_thickness,
				inner_dim[2] + wall_thickness,
			], center=true, radius=rounded_corner_radius, apply_to="all");

			translate([0, 0, inner_dim[2]/2])
			cube([
				inner_dim[0],
				inner_dim[1],
				inner_dim[2],
			], center=true);
		}

		// port cutouts
		translate([-mid_dist[0], +00.0, 0]) rotate([0, 0, 90]) cutout() rj45();
		translate([-mid_dist[0], +18.5, 0]) rotate([0, 0, 90]) cutout() microusb();
		translate([-mid_dist[0], -16.6, 0]) rotate([0, 0, 90]) cutout() audio();
		translate([-mid_dist[0], -27.5, 0]) rotate([0, 0, 90]) cutout() dc();

		translate([+mid_dist[0], -11.0, 0]) rotate([0, 0, 90]) cutout_below() microsd();

		translate([-02.0, mid_dist[1], 0]) cutout() hdmi();
		translate([-23.0, mid_dist[1], 0]) cutout() hdmi();
		translate([-43.5, mid_dist[1], 0]) cutout() usb();
		translate([+20.0, mid_dist[1], 0]) cutout() dip(6, 2);
		translate([+43.0, mid_dist[1], 0]) cutout() dip(6, 2);

		// tab cutouts
		tab_cutout();
		mirror([1, 0, 0]) tab_cutout();
		mirror([0, 1, 0]) tab_cutout();
		mirror([1, 0, 0]) mirror([0, 1, 0]) tab_cutout();

	}

	module _tab() {
		translate([-inner_dim[0]/2, inner_dim[1]/2 - wall_thickness, board_sit_height+board_thickness])
		rotate([90, 0, 0])
		linear_extrude(wall_thickness)
		children();
	}

	// tabs to keep board in
	module big_board_tab() {
		_tab() polygon([
			[-epsilon, -epsilon],
			[-epsilon, wall_thickness],
			[wall_thickness, wall_thickness]
		]);
	}
	big_board_tab();
	mirror([0, 1, 0]) big_board_tab();

	module small_board_tab() {
		_tab() translate([0, wall_thickness/2]) circle(wall_thickness/2);
	}
	mirror([1, 0, 0]) small_board_tab();
	mirror([1, 0, 0]) mirror([0, 1, 0]) small_board_tab();
}

bottom();
