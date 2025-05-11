#!/bin/bash

# === CONFIGURATION ===
SURNAME="Chapagain"  # <- CHANGE THIS TO YOUR LAST NAME
CR_FILE="CR-LEA.pml"
DKR_FILE="DKR-LEA.pml"

# === FILENAMES ===
CR_OUTPUT="CR-LEA_output.txt"
DKR_OUTPUT="DKR-LEA_output.txt"
ZIP_NAME="Assignment5_${SURNAME}.zip"

# === CHECK FILES EXIST ===
if [ ! -f "$CR_FILE" ]; then
    echo "❌ File $CR_FILE not found."
    exit 1
fi

if [ ! -f "$DKR_FILE" ]; then
    echo "❌ File $DKR_FILE not found."
    exit 1
fi

# === RUN CR-LEA SIMULATION ===
echo "▶ Running simulation for $CR_FILE..."
spin "$CR_FILE" > "$CR_OUTPUT"

# === RUN DKR-LEA SIMULATION ===
echo "▶ Running simulation for $DKR_FILE..."
spin -a "$DKR_FILE"
gcc -o pan pan.c
./pan -a > "$DKR_OUTPUT"

# === CLEANUP SPIN FILES ===
rm -f pan pan.c pan.h pan.m pan.b pan.t

# === PACKAGE FILES ===
echo "📦 Zipping files into $ZIP_NAME..."
zip "$ZIP_NAME" "$CR_FILE" "$CR_OUTPUT" "$DKR_FILE" "$DKR_OUTPUT"

echo "✅ Done. Submission archive created: $ZIP_NAME"
