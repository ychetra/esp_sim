# RFID Cut Station — Windows Deployment Guide

## 🚀 Option 1: One-Click EXE (Recommended)

### Build the EXE (run once)
1. Install Python 3.8+ from [python.org](https://python.org)
2. Open Command Prompt in this folder
3. Run:
   ```
   build_windows.bat
   ```
4. Output → `app\dist\RFID_CutStation\`

### Run
- Double-click `RFID_CutStation.exe`
- Browser opens automatically at `http://localhost:8080`
- Click ⚙️ **Settings** to configure your database

### First Time Setup
1. Click ⚙️ **Settings** in the top-right
2. Set **Database Mode** → SQL Server
3. Enter your SQL Server IP, database name, username, password
4. Set your **Table Name** and **Column Names** to match your existing DB
5. Click 💾 **Save Settings**
6. Restart the EXE

---

## 📦 Option 2: Run from Python (for development)

```bash
pip install pyserial
cd app
python main.py
```

For SQL Server: `pip install pyodbc`

---

## ⚙️ Configuration

All settings are in `config.ini` (also editable via the web dashboard):

| Setting | Description | Example |
|---------|-------------|---------|
| `mode` | Database mode | `sqlite` or `sqlserver` |
| `host` | SQL Server IP | `192.168.1.100` |
| `database` | Database name | `FactoryDB_Line1` |
| `table` | Table name | `tCutBundCard` |
| `card_column` | RFID card column | `CardNo` |
| `size_column` | Size column | `SizeName` |
| `qty_column` | Cut quantity column | `CutQty` |

---

## 🔌 Hardware

- **ESP32-C3 SuperMini** → USB to Windows PC
- **L298N Motor Driver** → GPIO 2 (IN1), GPIO 3 (IN2)
- **Firmware**: `esp32_rfid_motor.ino` (already flashed, no changes needed)
- Click 🔍 **Auto-Detect ESP32** to connect

---

## 📁 Files

```
app/
├── main.py           ← Main app (web server + serial + DB)
├── dashboard.html    ← Web UI (settings panel included)
├── db_handler.py     ← Database layer (SQLite + SQL Server)
├── serial_handler.py ← ESP32 communication
├── config.ini        ← Machine configuration
├── setup_db.py       ← Create test SQLite DB
└── fake_esp.py       ← ESP32 simulator (Mac testing)

esp32_rfid_motor/
└── esp32_rfid_motor.ino  ← ESP32 firmware (flash once)

build_windows.bat     ← Creates portable EXE
```
