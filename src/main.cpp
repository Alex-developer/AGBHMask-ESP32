/*
 * AGHubMAsk - An ASCOM driven Bahnitov mask
 *
 * Copyright (C)2021 Alex Greenland
 *
 * This file may be redistributed under the terms of the GPL license.
 * 
 */
#include "AGBHMask.h"

// Comment out to disable the display
#define USE_DISPLAY 
// If defined the mask will open at startup
#define OPEN_AT_STARTUP
// The delay for each servo step, reduce to speed up the motion
#define SERVO_STEP_DELAY 5

#ifdef USE_DISPLAY
  #include <heltec.h>
#endif

// The pin the manual button is connected to
#define MANUAL_BUTTON 17

/*
* The servo definitions. These work well for an SG90
*/
#define SERVO_MIN 1000
#define SERVO_MAX 2400

// Recommended PWM GPIO pins on the ESP32 include 2,4,12-19,21-23,25-27,32-33 
#define SERVO_PIN 18
#define SERVO_STEP 2

Servo bhMaskServo; 

int pos = 0;    // variable to store the servo position

OneButton btnManual = OneButton(
  MANUAL_BUTTON,  // Input pin for the button
  true,           // Button is active LOW
  true            // Enable internal pull-up resistor
);

maskStates state = CLOSED;
String ascomCommand;

void setup() {
  #ifdef USE_DISPLAY
  Heltec.begin(true, false, true);
  #endif

	ESP32PWM::allocateTimer(0);
	ESP32PWM::allocateTimer(1);
	ESP32PWM::allocateTimer(2);
	ESP32PWM::allocateTimer(3);
	bhMaskServo.setPeriodHertz(50);    // standard 50 hz servo
	bhMaskServo.attach(SERVO_PIN, SERVO_MIN, SERVO_MAX);

  Serial.begin(9600);  
  Serial.flush();

  btnManual.attachClick(handleClick);

  #ifdef OPEN_AT_STARTUP
  handleClick();
  #endif
}

static void handleClick() {
  if (state == CLOSED) {
    openMask(0);
    state= OPEN;
  } else {
    closeMask(0);
    state = CLOSED;
  }
}

/*
* Update the display whilst the mask is moving
*/
void updateDisplayMoving(String state, int pos, int source) {
  #ifdef USE_DISPLAY
  Heltec.display->clear();
  Heltec.display->setFont(ArialMT_Plain_16);
  if (source == 0) {
    Heltec.display->drawString(0, 0, "AG Mask Manual");
  } else {
    Heltec.display->drawString(0, 0, "AG Mask Ascom");
  }
  Heltec.display->drawString(0, 16, state + " " + String(pos));
  Heltec.display->display();
  #endif
}

/*
* Update the display
*/
void updateDisplayDone(String state) {
  #ifdef USE_DISPLAY
  Heltec.display->clear();
  Heltec.display->setFont(ArialMT_Plain_16);
  Heltec.display->drawString(0, 0, "AG Mask");
  Heltec.display->setFont(ArialMT_Plain_24);
  Heltec.display->drawString(0, 25, state);
  Heltec.display->display();
  #endif
}

/*
* The main loop. 
* Processes any ASCOM commands
*/
void loop() {
  btnManual.tick();

  if (Serial.available() > 0) {
    ascomCommand = Serial.readStringUntil('#');

    if (ascomCommand == "STATE") {
      Serial.print((int)!state);
      Serial.print("#");
    } 
    if (ascomCommand == "AGMASKVER") {
      Serial.print(VERSION);
      Serial.print("#");
    }     
    if (ascomCommand == "OPEN") {
      if (state == CLOSED) {
        state = OPEN;
        openMask(1);
      }
    } 
    if (ascomCommand == "CLOSE") {
      if (state == OPEN) {
        state = CLOSED;
        closeMask(1);
      }
    }
  
    
  }

}

/*
* Oen the Mask
*/
void openMask(int source) {
  for(int servoAngle = 180; servoAngle >= 0; servoAngle-=SERVO_STEP)
  {
    updateDisplayMoving("Opening", servoAngle, source); 
    bhMaskServo.write(servoAngle);
    delay(SERVO_STEP_DELAY);
  }
  updateDisplayDone("Open");
}

/*
* Close the mask
*/
void closeMask(int source) {
  for(int servoAngle = 0; servoAngle <= 180; servoAngle+=SERVO_STEP)
  { 
    updateDisplayMoving("Closing", servoAngle, source); 
    bhMaskServo.write(servoAngle);
    delay(SERVO_STEP_DELAY);
  }
  updateDisplayDone("Closed");
}