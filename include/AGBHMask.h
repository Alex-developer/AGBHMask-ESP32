#ifndef AGBHMASK
#define AGBHMASK

#include <Arduino.h>
#include <ESP32Servo.h>
#include "OneButton.h"

#define VERSION "1.0.0"

enum maskStates {
    CLOSED = 0,
    OPEN
};

void openMask(int);
void closeMask(int);

static void handleClick();

#endif