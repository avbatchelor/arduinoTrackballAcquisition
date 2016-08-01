#include <clockwork.h>

// Warning callback. Whenever the task execution time (TET) becomes larger than
// the allocated loop time (ALT), this function is auomatically triggered.
void tet_warning(long t) {
  Serial.print(t);
  Serial.println(" TET warning!");
}

// Instance the clockwork with 500 ms of ALT, also setting tet_warning() as
// warning callback
// If you don't need the callback, just use
// Clockwork cw(500);
Clockwork cw(500, tet_warning);

void setup() {
  Serial.begin(9600);
}

void loop() {
  // start the timing. This must be the very first call in your loop
  cw.start();

  delay(400 + random(0, 110));
  Serial.print("tet=");
  Serial.print(cw.tet());
  Serial.print(" delay=");
  Serial.print(cw.last_delay()); 
  Serial.print(" total=");
  Serial.println(cw.tet() + cw.last_delay());

  // Stop the taiming and wait until ALT ms elapsed since cw.start() call
  // This call returns true if TET < ALT, false otherwise.
  cw.stop();
}
