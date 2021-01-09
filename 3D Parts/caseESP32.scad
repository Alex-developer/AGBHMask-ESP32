// by Klaus Kloos V1.0 171126
// www.klkl.de
//
use <roundCornersCube.scad>

// was soll angezeigt werden?
showLid = true;                 // der Deckel
showBox = true;                // die Kiste
showESP = false;                // mit Platine an der Einbauposition
showComplete = false;           // mit Deckel, ergibt Aussenansicht
// the two switches
showHolesForSwitches = false;   // zur Bedienung mit etwas langem duennen
showSwitches = true;            // Tasten im Gehaese

// Konfiguration
mitUSBLoch = true;

// die Platine
pcbY = 65;                  // wenn das Display mittig ist, eigentlich 48
pcbX = 37;                  // ... 26 ist die richtige Breite 
pcbZ = 1.8;                 // die Dicke der Platine
antenneD = 4.7;             // die Bohrung fuer die Antenne

sz = 19;                    // die äußere Hoehe des Kastens, ohne Batterie
//sz = 30;                  // mit unterhalb liegender Batterie 
wall_thickness = 1.3;	    // thickness of the walls of the box (and lid)
lipHeight = 4;	            // the sides of the lid holding it in the box			

plugAddX = 2;               // was kommt durch den Stecker in x-Richtung dazu

dispX = 19+.7;              // die Vertiefung im Deckel
dispY = 33+.7;              // ...
dispZ = 6+.7;               // ...
visX = 14;                  // die sichtbare Fläche des Displays
visY = 26;                  // ...

// wo liegt die Platine
distPCBouterSideX = wall_thickness+.5;	// die Platine liegt an den Aussenwänden an
distPCBouterSideY = wall_thickness+.5;	// der zusaetzliche Abstand kommt durch die runden Ecken

// case details (these are *outer* diameters of the case) 
sx = pcbX + 2*distPCBouterSideX+plugAddX; 	// X dimension
sy = pcbY + 2*distPCBouterSideY;	        // Y dimension
r = 2.5;							        // the radius of the curves of the box walls.

module polyhole(h, d) 
{
	/* Nophead's polyhole code */
    n = max(round(2 * d),3);
    rotate([0,0,180])
        cylinder(h = h, r = (d / 2) / cos (180 / n), $fn = n);
}

module esp32(){
    pinH = 8;   // die Höhe der Pins
    union(){
        cube([1,pcbY,pinH]);                            // Pins1
        translate([pcbX-1,0,0]) cube([1,pcbY,pinH]);    // Pins2
        translate([0,0,pinH]) cube([pcbX,pcbY,pcbZ]);   // Platine
        
        translate([4,0,pinH+1]){                        // der Plastikaufbau ist nicht mittig
            cube([dispX,dispY,dispZ]);                  // das Diplay
            color ("black") translate([4,4,dispZ])cube([visX,visY,.3]); // der sichtbare Teil
        }
    }
}

module generateLid () {
    corner_lip_dia = 3.5;
    rahmenZ = .4;           // die Abdeckung um das Display herum, auch über der runden Antenne
    
    translate([0, sy+15, 0])
    difference(){
        union(){
            //Create the lid
            dL = .25;                   // ein Fummelfaktor für die Deckelpassung
            pcbZdist = 6.0;             // der Abstand der Platine von der Blende
            snapHeight = pcbZdist+2.5;  // Hoehe des Befestigungs-Clips
            pcbZplus = pcbZ+.2;         // mit Platz fuer die Platine
            translate([sx/2, sy/2, wall_thickness/2]) roundCornersCube(sx,sy,wall_thickness,r);
            //der Halter am Stecker
            translate([0,0,rahmenZ]){   //das Display liegt auf dem Deckel auf
                translate([corner_lip_dia+8,wall_thickness+dL, 0]) difference(){
                    cube([20,2,snapHeight]);
                    translate([-.1,1,pcbZdist]) cube([20.2,2,pcbZplus]); // Nut fuer Platine
                    halterX = 11.5;   // die Luecke für den USB Stecker
                    translate([(20-halterX)/2,-.1,0]) cube([halterX,10,10]);
                }
                // der Halter auf der anderen Seite
                translate([(sx-20)/2,(sy-dispY)/2+dispY+.5,0]) difference(){
                    cube([20,5,snapHeight]);
                    translate([-.1,-.1,pcbZdist]) cube([20.2,3,pcbZplus]); // Nut fuer Platine
                    translate([-.1,-.1,pcbZdist+pcbZ-.1]) cube([20.2,3.3-1.5,4]); // ueber Platine
                    halterLuecke = 3.5;   // hier sitzt die Antenne
                    translate([(20-halterLuecke)/2,-.1,0]) cube([halterLuecke,10,10]);
                }
            }
            // die Verstaerkungen an der Seite mit Auflage
            translate([wall_thickness+dL,corner_lip_dia*2,wall_thickness])
                        cube([wall_thickness,sy-corner_lip_dia*4,lipHeight]);
            translate([sx - wall_thickness*2-.2,corner_lip_dia*2, wall_thickness])
                        cube([wall_thickness,sy-corner_lip_dia*4,lipHeight]);
            translate([corner_lip_dia+8,sy - wall_thickness*2-dL,wall_thickness])
                cube([20,wall_thickness,lipHeight]);
            translate([(sx-dispX)/2+1.5,6,-.1]) switchPin();
            translate([(sx+dispX)/2-.5,6,-.1]) switchPin();
        }
        // and the holes
        translate([(sx-dispX)/2,(sy-dispY)/2,+rahmenZ]) cube([dispX, dispY, 5]);        // Display Vertiefung
        translate([sx/2+dispX/2-visX-1,(sy-visY)/2,-.1]) cube([visX, visY, 5]);           // Display Rahmen
        translate([29,15,rahmenZ]) cylinder(d=antenneD, h=wall_thickness+.2, $fn=20);   // Antenne
        if(showHolesForSwitches || showSwitches){
            translate([(sx-dispX)/2+1.5,6,-.1]) switchOutline("R");
            translate([(sx+dispX)/2-.5,6,-.1]) switchOutline("P");
        }
    }
}


module switchPin(){
    translate([0,1,wall_thickness-.2]) cylinder(h=4.9-wall_thickness, d=3, $fn=40);
}


module switchOutline(zeichen){ // wird für die Taster abgezogen
    if(showHolesForSwitches){
        cylinder(d=2.5, h=wall_thickness+.2, $fn=20);
    }
    if(showSwitches){
        difference(){
            z = wall_thickness+.2;
            knopf=8;
            union(){    // aussen, kommt weg
                translate([0,2,0]) cylinder(d=knopf, h=z, $fn=20);
                translate([-4,2,0]) cube([knopf, 8, z]);
            }
            // innen, bleibt stehen
            s=.7;   // der Spalt am Knopf .5 war zu wenig
            innen = knopf-2*s;
            translate([0,2,0]) cylinder(d=innen, h=wall_thickness+.2, $fn=20);
            translate([-innen/2,2,0]) cube([innen, 9, z]);
        }
        einpressTiefe = 1;
        fontHeight = 4;
        rotate([180,0,90]) translate([.5,-fontHeight/2,-einpressTiefe]) linear_extrude(2)
            text(zeichen, font = "Liberation Sans:style=Bold", fontHeight, halign = "left");
    }
}


module generateBox(){
    plugZ = 11;
    plugY = 15;
    plugX = 11;
    difference() {
        // the outer box
        translate([sx/2, sy/2, sz/2-.1 ]) roundCornersCube(sx,sy,sz, r);
        //cut off the 'lid' of the box
        translate([-0.1,-0.1, sz - wall_thickness]) cube([sx+1,sy+1,wall_thickness + 1]);
        //hollow it out
        innenY = sy - (wall_thickness*2);
        translate([sx/2, sy/2, sz/2 + wall_thickness])
            roundCornersCube(sx - (wall_thickness*2) , innenY , sz, r);
        if(mitUSBLoch){
            translate([(sx-plugX)/2, sy-10, sz-wall_thickness-6.5])
                cube([plugX, plugY, plugZ]);
        }
    }
}

if(showLid){
    generateLid();
}
if(showBox){
    generateBox();
}
if(showComplete){
    translate([sx/2, sy/2, sz-.5]) roundCornersCube(sx,sy,wall_thickness,r); 
}
if(showESP){
    translate([distPCBouterSideX,distPCBouterSideY,sz-12]) esp32();
}

