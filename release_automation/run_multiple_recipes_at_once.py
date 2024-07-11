import subprocess
import time
import os
from datetime import datetime

# Get the directory of the current Python script
current_dir = os.path.dirname(os.path.abspath(__file__))

# Change to the middleware-recipes directory
os.chdir(os.path.join(current_dir, 'middleware-recipes'))

# Define the paths
recipe_list_path = '../Recipe_List/MongoDB_identifiers.txt'
script_command = 'python ../autopkg/Code/autopkg run -vv'

log_folder_name = os.path.splitext(os.path.basename(recipe_list_path))[0].replace('.', '').replace('/', '')

# Create a 'logs' directory if it doesn't exist in the current directory
logs_dir = os.path.join(current_dir, 'logs', f"{log_folder_name}_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}")
os.makedirs(logs_dir, exist_ok=True)

# Read the list of identifiers
with open(recipe_list_path, 'r') as file:
    identifiers = [line.strip() for line in file]

# List to keep track of subprocesses
processes = []

# Start a new command prompt for each identifier
for identifier in identifiers:
    # Generate a unique log file name for each subprocess with current date and time
    current_datetime = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    log_file = os.path.join(logs_dir, f"{current_datetime}_{identifier.replace('/', '_').replace(':', '')}_log.txt")
    with open(log_file, 'w') as log:
        cmd = f'{script_command} {identifier}'
        # Redirect the output to the log file
        process = subprocess.Popen(['cmd', '/c', cmd], shell=True, stdout=log, stderr=log)
        processes.append(process)

# Wait for all subprocesses to complete
for process in processes:
    process.wait()

print("All processes have completed.")
print(" please find the log files at : ",logs_dir)