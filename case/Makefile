all: build build/bottom.stl build/top.stl

build:
	@mkdir -p build

build/bottom.stl: bottom.scad cutouts.scad roundedcube.scad vars.scad
	openscad bottom.scad -o build/bottom.stl

build/top.stl: top.scad cutouts.scad roundedcube.scad vars.scad
	openscad top.scad -o build/top.stl
