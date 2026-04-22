#!/usr/bin/env python3
"""
Fake ESP32 — Simulates the real ESP hardware:
  - Low-freq RFID card reader
  - Motor (stepper/DC)
  - LCD display (16x2 or I2C)

Protocol:
  Sends:    CARD:<card_number>\n
  Receives: CUT:<quantity>\n

Usage:
  1. Start socat (see start.sh)
  2. Start rfid_server.py on one port
  3. Run this on the OTHER port
"""

import serial
import sys
import time

# ─── CONFIGURATION ───────────────────────────────────────────────
ESP_PORT = '/dev/ttys011'
BAUD_RATE = 115200
MOTOR_DELAY = 0.5  # Seconds per motor spin (simulated)
# ─────────────────────────────────────────────────────────────────


def lcd_display(line1, line2=""):
    """Simulate LCD 16x2 display output."""
    print("┌──────────────────┐")
    print(f"│ {line1:<16} │")
    print(f"│ {line2:<16} │")
    print("└──────────────────┘")


def motor_spin(total_cuts):
    """Simulate motor spinning with LCD countdown."""
    print()
    print(f"🔧 Motor starting... {total_cuts} cuts")
    print()

    for i in range(1, total_cuts + 1):
        # Simulate LCD showing count
        lcd_display(f"Cutting: {i}/{total_cuts}", "Motor: ON")

        # Simulate motor spin
        print(f"  🔄 Motor spin {i}/{total_cuts}")
        time.sleep(MOTOR_DELAY)

    # Done
    print()
    lcd_display("Done!", f"Total: {total_cuts} cuts")
    print("✅ Motor finished!\n")


def main():
    global ESP_PORT

    if len(sys.argv) > 1:
        ESP_PORT = sys.argv[1]

    print("=" * 50)
    print("  🤖 Fake ESP32 (RFID + Motor + LCD)")
    print("=" * 50)
    print(f"  📡 Port: {ESP_PORT}")
    print(f"  ⚡ Baud: {BAUD_RATE}")
    print("=" * 50)
    print()

    try:
        ser = serial.Serial(ESP_PORT, BAUD_RATE, timeout=2)
    except serial.SerialException as e:
        print(f"❌ Cannot open port {ESP_PORT}: {e}")
        print("💡 Did you start socat?")
        sys.exit(1)

    print("✅ ESP Ready. Waiting for card tap...\n")

    # Show initial LCD
    lcd_display("Ready", "Tap card...")

    try:
        while True:
            # Simulate card tap (user input)
            card = input("\n🏷️  Tap card (enter number): ").strip()

            if not card:
                continue

            if card.lower() in ('quit', 'exit', 'q'):
                break

            # ─── RFID Reader detected card ───
            print(f"\n📡 RFID detected: {card}")
            lcd_display("Card detected!", card)
            time.sleep(0.3)

            # Send card to server
            msg = f"CARD:{card}\n"
            ser.write(msg.encode())
            print(f"📤 Sent to server: {msg.strip()}")

            # Show waiting on LCD
            lcd_display("Checking DB...", "Please wait")

            # Wait for response
            start_time = time.time()
            response = None

            while time.time() - start_time < 5:  # 5 second timeout
                if ser.in_waiting:
                    raw = ser.readline()
                    try:
                        response = raw.decode('utf-8').strip()
                    except UnicodeDecodeError:
                        continue
                    break
                time.sleep(0.01)

            if response is None:
                print("⏰ Timeout! No response from server")
                lcd_display("ERROR!", "No response")
                continue

            print(f"📥 Received: {response}")

            # ─── Process response ───
            if response.startswith("CUT:"):
                qty = int(response.split(":")[1])

                if qty == 0:
                    print("❌ Card not found or no cuts assigned")
                    lcd_display("Card Invalid!", "CutQty = 0")
                else:
                    # Run the motor!
                    motor_spin(qty)

            else:
                print(f"⚠️  Unknown response: {response}")
                lcd_display("ERROR!", "Bad response")

            # Back to ready
            lcd_display("Ready", "Tap card...")

    except KeyboardInterrupt:
        print("\n🛑 ESP stopped.")
        ser.close()


if __name__ == '__main__':
    main()
