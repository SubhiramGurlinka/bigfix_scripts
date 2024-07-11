# Import necessary modules
import os
import re
import shutil

# Function to check if the string exists in the file content
def check_string_in_file(file_path, search_string):
    if not os.path.isfile(file_path):
        raise FileNotFoundError(f"The file {file_path} does not exist.")
    
    with open(file_path, 'r') as file:
        content = file.read()
        if search_string in content:
            return True
        else:
            return False

# Function to get the path and ID from the content of the file
def find_path_and_id(file_path,path_pattern):
    with open(file_path, 'r') as file:
        file_contents = file.read()
    # Search for matches
    match = re.search(pattern, file_contents)
    if match:
        # Extract the groups
        path = match.group(1)
        number = match.group(2)
        print("printing path and number")
        print(path, number)
        return path,number
    else:
        print("No match found.")

# Function to convert the extracted path to a valid windows path
def convert_to_windows_path(path):
    # Replace forward slashes with backslashes
    windows_path = path.replace('/', '\\')
    windows_path = os.path.normpath(windows_path)
    return windows_path

# Function to copy the file starting with the fixlet id ( this is a sample function created to verify if the file is being copied)
def copy_files_starting_with_number(src_folder, dest_folder, number):
    # Ensure the destination folder exists
    if not os.path.exists(dest_folder):
        os.makedirs(dest_folder)

    # List all files in the source folder
    for filename in os.listdir(src_folder):
        # Check if the filename starts with the given number
        if filename.startswith(str(number)):
            # Construct full file paths
            src_file = os.path.join(src_folder, filename)
            dest_file = os.path.join(dest_folder, filename)
            return src_file
            # Copy the file to the destination folder
            shutil.copy(src_file, dest_file)
            print(f"Copied {filename} to {dest_folder}")

def find_file_starting_with_number(folder, number):
    # Ensure the folder exists
    if not os.path.exists(folder):
        print(f"Folder '{folder}' does not exist.")
        return None

    # Convert the number to string for comparison
    number_str = str(number)

    # List all files in the folder
    for filename in os.listdir(folder):
        # Check if the filename starts with the given number
        if filename.startswith(number_str):
            # Return the full path of the matching file
            return os.path.join(folder, filename)
    
    # No file starting with the given number was found
    print(f"No file starting with '{number_str}' found in '{folder}'.")
    return None

def get_prefix(number):
    """Get the first 6 digits of the given number as a prefix."""
    number_str = str(number)
    return number_str[:6]

def manage_files_with_prefix(folder, prefix, new_file_path):
    # Ensure the folder exists
    if not os.path.exists(folder):
        print(f"Folder '{folder}' does not exist.")
        return

    # List all files in the folder that start with the given prefix
    files = [f for f in os.listdir(folder) if f.startswith(prefix)]
    
    # Extract numbers from filenames and store in a dictionary to check uniqueness
    file_numbers = {}
    for file in files:
        match = re.match(rf"{prefix}(\d+)", file)
        if match:
            num = int(match.group(1))
            if num in file_numbers:
                print(f"Duplicate number found in filenames: {num}")
                return  # or handle as needed, e.g., skip, log, etc.
            file_numbers[num] = file
    print(file_numbers)

    # Check the number of files
    if len(file_numbers) < 3:
        # Less than 3 files: Copy the new file to the folder
        dest_file_path = os.path.join(folder, os.path.basename(new_file_path))
        shutil.copy(new_file_path, dest_file_path)
        print(f"Copied {new_file_path} to {folder}")
    elif len(file_numbers) == 3:
        # Exactly 3 files: Process to replace the least numbered file
        sorted_numbers = sorted(file_numbers.keys())
        min_number = sorted_numbers[0]
        max_number = sorted_numbers[-1]
        
        # Determine the file to remove (with the smallest number)
        file_to_remove = file_numbers[min_number]
        file_to_remove_path = os.path.join(folder, file_to_remove)
        
        # Remove the file with the smallest number
        os.remove(file_to_remove_path)
        print(f"Removed file: {file_to_remove}")
        
        # Copy the new file to the folder
        dest_file_path = os.path.join(folder, os.path.basename(new_file_path))
        shutil.copy(new_file_path, dest_file_path)
        print(f"Copied {new_file_path} to {folder}")
    else:
        print("Number of files with the prefix is not 3.")

error_list = []
# Define the path to the content file
# content_file_path = 'output1.txt'
folder_path = r"C:\Users\sgbsubhiram.gurlinka\Documents\recipe_logs"
for root, dirs, files in os.walk(folder_path):
    for file in files:
        content_file_path = os.path.join(root, file)
        # Define the string you want to search for
        search_string = 'new version downloaded'

        # Check if the string exists
        string_exists = check_string_in_file(content_file_path, search_string)

        recipe_failed_string = "The following recipes failed:"
        recipe_failed = check_string_in_file(content_file_path, recipe_failed_string)
        if recipe_failed:  
            print("This recipe failed: ",content_file_path)
            error_list.append(content_file_path)

        # Define the regex pattern
        pattern = "content_file_pathname': '(?P<path>[^']*)/(?P<id>\d+) '" # tested and works

        if string_exists:
            print(f"The string '{search_string}' was found in the file.")
            path,id = find_path_and_id(content_file_path,pattern)
            if path and id:
                valid_path = convert_to_windows_path(path)
                print(valid_path)
                print(id)
                dest_path = r"C:\Users\sgbsubhiram.gurlinka\Documents\Middleware\code\trail_automation_repo\Fixlets\Updates"
                new_file_path = find_file_starting_with_number(valid_path,id)
                print(copy_files_starting_with_number)
                # get the prefix
                prefix = get_prefix(id)
                manage_files_with_prefix(dest_path,prefix,new_file_path)

        else:
            print(f"The string '{search_string}' was not found in the file. So no files copied to the given path")

if error_list:
    print("Please verify the below recipes again, It looks like one or more processors failed in these recipes while execution")

    print(" The following recipes failed: ")
    for error in error_list:
        print(error)

# -----------------------now starting the edit