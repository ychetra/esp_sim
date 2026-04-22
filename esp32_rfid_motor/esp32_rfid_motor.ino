/*
 * ESP32-C3 + L298N + DC Motor — Cut Controller
 *
 * Wiring:
 *   GPIO 2  → IN1   → OUT1 → Motor wire 1
 *   GPIO 3  → IN2   → OUT2 → Motor wire 2
 *   ENA     → Jumper ON
 *   ESP 5V  → L298N "+12V" terminal
 *   ESP GND → L298N GND
 *
 * Board: ESP32C3 Dev Module
 * USB CDC On Boot: Enabled
 */

#define MOTOR_A 2   // IN1 - use GPIO 2 (safe, no JTAG)
#define MOTOR_B 3   // IN2 - use GPIO 3 (safe, no JTAG)

#define CUT_SPIN_TIME  3000
#define CUT_PAUSE_TIME  500

String buf = "";

void setup() {
  Serial.begin(115200);

  pinMode(MOTOR_A, OUTPUT);
  pinMode(MOTOR_B, OUTPUT);
  digitalWrite(MOTOR_A, LOW);
  digitalWrite(MOTOR_B, LOW);

  delay(2000);
  Serial.println("READY - type ON to test motor");
}

void loop() {
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\n') {
      buf.trim();
      handleCmd(buf);
      buf = "";
    } else if (c != '\r') {
      buf += c;
    }
  }
  delay(5);
}

void handleCmd(String cmd) {
  if (cmd == "ON") {
    Serial.println("MOTOR ON");
    digitalWrite(MOTOR_A, HIGH);
    digitalWrite(MOTOR_B, LOW);

  } else if (cmd == "OFF") {
    Serial.println("MOTOR OFF");
    digitalWrite(MOTOR_A, LOW);
    digitalWrite(MOTOR_B, LOW);

  } else if (cmd.startsWith("CUT:")) {
    int qty = cmd.substring(4).toInt();
    if (qty > 0) {
      Serial.print("CUTTING:");
      Serial.println(qty);

      for (int i = 0; i < qty; i++) {
        digitalWrite(MOTOR_A, HIGH);
        digitalWrite(MOTOR_B, LOW);
        delay(CUT_SPIN_TIME);
        digitalWrite(MOTOR_A, LOW);
        digitalWrite(MOTOR_B, LOW);
        delay(CUT_PAUSE_TIME);
      }

      Serial.println("OK");
    }
  } else if (cmd == "PING") {
    Serial.println("PONG");
  }
}
