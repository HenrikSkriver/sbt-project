#!/usr/bin/env python3
"""
seed_data.py — Seed a local database with test data.

This is an example script. Adapt it to your project's database
and ORM setup.

Usage (called from just recipes):
    python3 scripts/seed_data.py
"""

import json
import sys


def main():
    print("Seeding test data...")
    print("")

    # Example: this would connect to your local database and insert
    # test records. Replace with actual DB logic for your project.

    sample_data = [
        {"entity": "User", "count": 10, "note": "admin + 9 regular users"},
        {"entity": "Product", "count": 50, "note": "across 5 categories"},
        {"entity": "Order", "count": 25, "note": "various statuses"},
    ]

    for item in sample_data:
        print(f"  → {item['entity']}: {item['count']} records ({item['note']})")

    print("")
    print("✓ Seed data inserted (dry-run — connect to your DB to enable)")


if __name__ == "__main__":
    main()
