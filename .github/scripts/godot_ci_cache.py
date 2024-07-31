# 
# Fixes https://github.com/godotengine/godot/issues/77508
# original script source: https://gist.github.com/d6e/5ed21c37a8ac294db26532cc6af5c61c
#

import os
import subprocess
import time
import re
from pathlib import Path

# Set the path to your Godot project and Godot executable
GODOT_PROJECT_PATH = Path(".")
GODOT_EXECUTABLE = "godot"  # or the path to your Godot executable
GODOT_LOG_FILE = Path("artifacts") / "godot_output.log"  # Log file to store Godot output

print("Building godot cache...", flush=True)
start_time = time.time()

# Step 1: Recursively find all '.import' files and collect the expected imported file paths
expected_imported_files = set()
for import_file in GODOT_PROJECT_PATH.rglob('*.import'):
    content = import_file.read_text()
    matches = re.findall(r'dest_files=\["(res://\.godot/imported/.+?)"\]', content)
    expected_imported_files.update(matches)

total_imports = len(expected_imported_files)
print(f"Found {total_imports} references to imported files...", flush=True)

# Step 2: Launch Godot in the background to start the import process
print("Starting Godot to import files...", flush=True)
GODOT_LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
with GODOT_LOG_FILE.open("w") as log_file:
    try:
        godot_process = subprocess.Popen(
            [GODOT_EXECUTABLE, "--path", str(GODOT_PROJECT_PATH), "--editor", "--headless"],
            stdout=log_file,
            stderr=subprocess.STDOUT
        )
    except Exception as e:
        print(f"Failed to start Godot: {e}")
        exit(1)

# Step 3: Continually check if the expected imported files exist
imported_folder = GODOT_PROJECT_PATH / ".godot/imported"
while expected_imported_files:
     # Wait until the imported directory exists
    if not imported_folder.exists():
        print(f"Waiting for the imported directory to be created by Godot...")
        time.sleep(1)
        continue

    for expected_path in list(expected_imported_files):
        imported_file_path = GODOT_PROJECT_PATH / expected_path.replace("res://", "")
        if imported_file_path.exists():
            expected_imported_files.remove(expected_path)
    imported_count = total_imports - len(expected_imported_files)
    print(f"Imported {imported_count} / {total_imports} files...")
    time.sleep(1)  # Wait for a second before checking again

elapsed_time = time.time() - start_time
print(f"Imported all files in {elapsed_time:.2f} seconds.", flush=True)

# Step 4: Once all files have been imported, quit Godot
try:
    print("Quitting Godot...", flush=True)
    start_time = time.time()
    godot_process.terminate()
    godot_process.wait(timeout=10)
    
except subprocess.TimeoutExpired:
    print("Godot did not terminate in a timely manner; killing the process.")
    godot_process.kill()
finally:
    elapsed_time = time.time() - start_time
    print(f"Godot has been closed in {elapsed_time:.2f} seconds.", flush=True)

print("All files have been imported. Godot has been closed.")

