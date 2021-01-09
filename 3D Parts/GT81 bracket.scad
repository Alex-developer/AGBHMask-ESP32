d = 103;

difference() {
cube(size = [70,20,42], center = true);

translate([0,45,0])
    rotate([0,90,0])
        cylinder(h=80, r1=d/2, r2=d/2, center=true, $fn=360);
    
translate([25,-8.9,0])
    cube(size = [10,2.5,60], center = true);
translate([-25,-8.9,0])
    cube(size = [10,2.5,60], center = true);    
}