#!/usr/bin/env python3
"""Direct ESP32 serial test — waits for READY then sends commands."""
import serial
import time

PORT = "/dev/cu.usbmodem21201"
BAUD = 115200

print(f"Opening {PORT}...")
ser = serial.Serial(PORT, BAUD, timeout=1)

# ESP32-C3 resets when serial connects — wait for READY
print("Waiting for ESP32 to boot (up to 10s)...")
start = time.time()
ready = False
while time.time() - start < 10:
    if ser.in_waiting:
        line = ser.readline().decode(errors='ignore').strip()
        print(f"  ESP: {line}")
        if "READY" in line:
            ready = True
            break
    time.sleep(0.1)

if not ready:
    print("⚠️  No READY received. Trying anyway...")
else:
    print("✅ ESP32 is READY!\n")

# Test 1: PING
print("--- Test 1: PING ---")
ser.write(b"PING\n")
time.sleep(1)
while ser.in_waiting:
    print(f"  ESP: {ser.readline().decode(errors='ignore').strip()}")

# Test 2: CUT:1 (just 1 revolution to test)
print("\n--- Test 2: CUT:1 ---")
print("  Sending CUT:1 ... watch the motor!")
ser.write(b"CUT:1\n")

# Wait up to 30 seconds for response
start = time.time()
while time.time() - start < 30:
    if ser.in_waiting:
        line = ser.readline().decode(errors='ignore').strip()
        print(f"  ESP: {line}")
        if line == "OK":
            print("  ✅ Motor cycle complete!")
            break
    time.sleep(0.1)
else:
    print("  ❌ Timeout — no OK received")

ser.close()
print("\nDone!")
