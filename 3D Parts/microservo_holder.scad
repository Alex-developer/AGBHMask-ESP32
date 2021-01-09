micW = 22 + 1;
micL = 12 + 1;
micH = 15 + 1;

wingWidth = 5;
cicR = 1;

thickness = 2;
difference() {
    shell();
    
    translate([thickness, 
    thickness, thickness])
        cube([micW, micL, micH]);
    
    translate([-1, 
    thickness+2, thickness])
        cube([micW+10, micL-4, 
        micH-2]);
    
    translate([thickness+2, 
    -1, thickness])
        cube([micW-4, micL+10, 
        micH+2]);
}

module shell() {
    cube([
        micW+thickness*2,
        micL+thickness*2,
        micH+thickness
    ]);
    translate([-wingWidth+thickness,
            thickness,
            micH
    ]) cube([micW+wingWidth*2,
            micL,
            thickness]);
    translate([-wingWidth/2+thickness,
            thickness+micL/2,
            micH+thickness+1.5])
        pin();
    translate([micW+thickness+wingWidth/2,
            thickness+micL/2,
            micH+thickness+1.5])
        pin();
}

module pin() {
    //Cylinders are mispositioned
    //cylinder(h=thickness+1, r=1, center=true, $fn=100);
}