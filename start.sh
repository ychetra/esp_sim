#!/bin/bash
# ============================================
#  ESP Simulation Launcher
#  Start this first, then open 2 more terminals
# ============================================

echo "============================================"
echo "  🔌 Starting Virtual Serial Ports"
echo "============================================"
echo ""
echo "This will create two connected virtual ports."
echo "Look for the /dev/ttysXXX lines below."
echo ""
echo "Then in separate terminals:"
echo "  Terminal 2:  python3 rfid_server.py /dev/ttysXXX"
echo "  Terminal 3:  python3 fake_esp.py /dev/ttysYYY"
echo ""
echo "Press Ctrl+C to stop."
echo "============================================"
echo ""

socat -d -d pty,raw,echo=0 pty,raw,echo=0
