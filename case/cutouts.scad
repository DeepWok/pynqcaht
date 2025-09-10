margin = 1;

module _square(w, h) {
	translate([0, h/2])
	square([w+2*margin, h+2*margin], center=true);
}

module _circle(r) {
	translate([0, r])
	circle(r + margin);
}

module hdmi() {
	translate([0, 0.7, 0]) _square(14.5, 5);
}

module usb() {
	translate([0, 1.2, 0]) _square(13, 5.8);
}

module dip(w, h, ) {
	_square(2.54*w, 2.54*h);
}

module rj45() {
	translate([0, 2, 0])
	_square(12, 10);
}

module microusb() {
	_square(8, 2.5);
}

module audio() {
	translate([0, 1.2, 0])
	_circle(1.75);
}

module dc() {
	translate([0, 0.6, 0])
	_circle(3);
}

module microsd() {
	_square(15, 1);
}
