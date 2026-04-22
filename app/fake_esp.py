#!/usr/bin/env python3
"""
Fake ESP32-C3 — Simulates real hardware for testing.
Updated protocol: CUT:<qty>:<size_name>

Usage:
  1. Start socat virtual ports
  2. Start main.py (app) on one port
  3. Run this on the OTHER port
"""

import serial
import sys
import time

ESP_PORT = '/dev/ttys011'
BAUD_RATE = 115200
MOTOR_DELAY = 0.4


def lcd_display(line1, line2=""):
    print("┌──────────────────┐")
    print(f"│ {line1:<16} │")
    print(f"│ {line2:<16} │")
    print("└──────────────────┘")


def motor_spin(total_cuts, size_name):
    print(f"\n🔧 Motor starting... {total_cuts} cuts for size [{size_name}]")
    print()

    for i in range(1, total_cuts + 1):
        lcd_display(f"Size:{size_name} {i}/{total_cuts}", "Motor: ON")
        print(f"  🔄 Motor spin {i}/{total_cuts}")
        time.sleep(MOTOR_DELAY)

    print()
    lcd_display("Done!", f"{size_name} x{total_cuts}")
    print("✅ Motor finished!\n")


def main():
    global ESP_PORT

    if len(sys.argv) > 1:
        ESP_PORT = sys.argv[1]

    print("=" * 50)
    print("  🤖 Fake ESP32-C3 (RFID + Motor + LCD)")
    print("=" * 50)
    print(f"  📡 Port: {ESP_PORT}")
    print(f"  ⚡ Baud: {BAUD_RATE}")
    print("=" * 50)
    print()

    try:
        ser = serial.Serial(ESP_PORT, BAUD_RATE, timeout=2)
    except serial.SerialException as e:
        print(f"❌ Cannot open port {ESP_PORT}: {e}")
        print("💡 Start socat first")
        sys.exit(1)

    print("✅ ESP Ready\n")
    lcd_display("Ready", "Tap card...")

    try:
        while True:
            card = input("\n🏷️  Tap card (enter number): ").strip()

            if not card:
                continue
            if card.lower() in ('quit', 'exit', 'q'):
                break

            print(f"\n📡 RFID detected: {card}")
            lcd_display("Card detected!", card)
            time.sleep(0.2)

            # Send to app
            msg = f"CARD:{card}\n"
            ser.write(msg.encode())
            print(f"📤 Sent: {msg.strip()}")
            lcd_display("Checking DB...", "Please wait")

            # Wait for response
            start = time.time()
            response = None

            while time.time() - start < 5:
                if ser.in_waiting:
                    raw = ser.readline()
                    try:
                        response = raw.decode('utf-8').strip()
                    except UnicodeDecodeError:
                        continue
                    break
                time.sleep(0.01)

            if response is None:
                print("⏰ Timeout!")
                lcd_display("ERROR!", "No response")
                continue

            print(f"📥 Received: {response}")

            # Parse: CUT:<qty>:<size>
            if response.startswith("CUT:"):
                parts = response.split(":")
                qty = int(parts[1])
                size_name = parts[2] if len(parts) > 2 else ""

                if qty == 0:
                    print(f"❌ Card not found or no cuts")
                    lcd_display("Card Invalid!", size_name or "Not Found")
                else:
                    motor_spin(qty, size_name)
            else:
                print(f"⚠️  Unknown: {response}")
                lcd_display("ERROR!", "Bad response")

            lcd_display("Ready", "Tap card...")

    except KeyboardInterrupt:
        print("\n🛑 ESP stopped.")
        ser.close()


if __name__ == '__main__':
    main()
