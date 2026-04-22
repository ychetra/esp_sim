#!/usr/bin/env python3
"""
Setup the SQLite database with sample RFID card data.
Run this ONCE to create the database and populate test data.
"""

import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), 'factory.db')

def setup():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Create cards table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            CardNo TEXT UNIQUE NOT NULL,
            CutQty INTEGER NOT NULL DEFAULT 0,
            WorkerName TEXT,
            Status TEXT DEFAULT 'active'
        )
    ''')

    # Insert sample data
    sample_cards = [
        ('123456', 5, 'Worker A', 'active'),
        ('789012', 3, 'Worker B', 'active'),
        ('345678', 10, 'Worker C', 'active'),
        ('111111', 0, 'Worker D (empty)', 'active'),
        ('999999', 0, '', 'inactive'),  # Invalid card
    ]

    for card_no, cut_qty, name, status in sample_cards:
        cursor.execute('''
            INSERT OR REPLACE INTO cards (CardNo, CutQty, WorkerName, Status)
            VALUES (?, ?, ?, ?)
        ''', (card_no, cut_qty, name, status))

    conn.commit()
    conn.close()

    print("✅ Database created:", DB_PATH)
    print()
    print("📋 Sample cards:")
    print("  CardNo   | CutQty | Worker         | Status")
    print("  ---------+--------+----------------+--------")
    for card_no, cut_qty, name, status in sample_cards:
        print(f"  {card_no:<9}| {cut_qty:<6} | {name:<14} | {status}")

if __name__ == '__main__':
    setup()
