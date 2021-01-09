## AGBHMask
An automated Bahtinov mask.

The prototype used an ESP32 (https://www.amazon.co.uk/MakerHawk-Development-0-96inch-Display-Compatible/dp/B076P8GRWV) with a built in screen.

The SG90 servo (https://www.amazon.co.uk/Longruner-Helicopter-Airplane-Controls-KY66-10/dp/B072J59PKZ) is driven directly from the ESP32.

All other components are 3d printed.

The ASCOM protocol is very simple.

Send STATE# to the device and it will return the open or closed stats
Send OPEN# to remove the mask from the scope
Send CLOSE# to close the mask over the scope