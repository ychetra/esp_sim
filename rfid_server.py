#!/usr/bin/env python3
"""
RFID Server — sits between ESP (or fake ESP) and the database.

Protocol:
  ESP sends:    CARD:<card_number>\n
  Server replies: CUT:<quantity>\n    (0 = not found or inactive)

Usage:
  1. Start virtual serial:  socat -d -d pty,raw,echo=0 pty,raw,echo=0
  2. Note the two /dev/ttysXXX ports
  3. Set SERVER_PORT below to one of them
  4. Run:  python3 rfid_server.py
"""

import serial
import sqlite3
import os
import sys
import time

# ─── CONFIGURATION ───────────────────────────────────────────────
# Change this to your virtual serial port (the one socat gives you)
# Or pass as command-line argument: python3 rfid_server.py /dev/ttys010
SERVER_PORT = '/dev/ttys010'
BAUD_RATE = 115200
DB_PATH = os.path.join(os.path.dirname(__file__), 'factory.db')
# ─────────────────────────────────────────────────────────────────

def lookup_card(card_no):
    """Query database for card and return CutQty (0 if not found/inactive)."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        'SELECT CutQty, WorkerName, Status FROM cards WHERE CardNo = ?',
        (card_no,)
    )
    row = cursor.fetchone()
    conn.close()

    if row is None:
        print(f"  ❌ Card {card_no} NOT FOUND in database")
        return 0

    cut_qty, worker_name, status = row

    if status != 'active':
        print(f"  ⚠️  Card {card_no} is INACTIVE (worker: {worker_name})")
        return 0

    print(f"  ✅ Card {card_no} → Worker: {worker_name}, CutQty: {cut_qty}")
    return cut_qty


def main():
    global SERVER_PORT

    # Allow passing port as argument
    if len(sys.argv) > 1:
        SERVER_PORT = sys.argv[1]

    # Check database exists
    if not os.path.exists(DB_PATH):
        print("❌ Database not found! Run setup_db.py first:")
        print("   python3 setup_db.py")
        sys.exit(1)

    print("=" * 50)
    print("  🏭 RFID Server")
    print("=" * 50)
    print(f"  📡 Port: {SERVER_PORT}")
    print(f"  🗄️  DB:   {DB_PATH}")
    print(f"  ⚡ Baud: {BAUD_RATE}")
    print("=" * 50)
    print("  Waiting for ESP connection...")
    print()

    try:
        ser = serial.Serial(SERVER_PORT, BAUD_RATE, timeout=1)
    except serial.SerialException as e:
        print(f"❌ Cannot open port {SERVER_PORT}: {e}")
        print()
        print("💡 Did you start socat?")
        print("   socat -d -d pty,raw,echo=0 pty,raw,echo=0")
        sys.exit(1)

    print("✅ Serial port opened. Listening...\n")

    try:
        while True:
            if ser.in_waiting:
                raw = ser.readline()
                try:
                    line = raw.decode('utf-8').strip()
                except UnicodeDecodeError:
                    print(f"  ⚠️  Bad data received: {raw}")
                    continue

                if not line:
                    continue

                print(f"📥 Received: {line}")

                if line.startswith("CARD:"):
                    card_no = line.split(":", 1)[1].strip()
                    cut_qty = lookup_card(card_no)

                    response = f"CUT:{cut_qty}\n"
                    ser.write(response.encode())
                    print(f"📤 Sent: {response.strip()}")
                    print()
                else:
                    print(f"  ⚠️  Unknown command: {line}")

            time.sleep(0.01)  # Small delay to prevent CPU spinning

    except KeyboardInterrupt:
        print("\n🛑 Server stopped.")
        ser.close()


if __name__ == '__main__':
    main()
