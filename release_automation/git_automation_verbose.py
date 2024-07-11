import subprocess
import sys
import os
from datetime import datetime
import time

# currently stable and can be used in deployement

# function run the subprocess coammnd
def run_command(command, cwd=None):
    print("-----------------------------")
    print(f"Running command: {command}")
    result = subprocess.run(command, shell=True, cwd=cwd, capture_output=True, text=True)
    print(f"Command '{command}' output:\n{result.stdout}")
    print("-----------------------------")
    return result.stdout.strip()

def get_highest_tag(tags):
    versions = [tag for tag in tags if tag.startswith('v')]
    versions.sort(key=lambda s: list(map(int, s.lstrip('v').split('.'))))
    return versions[-1] if versions else None

def has_unstaged_changes():
    try:
        # Run the 'git status' command
        result = run_command("git status --porcelain", cwd=repo_path)
        print(result)
        # Check the output of the command
        if result:
            return True
        else:
            return False
    except Exception as e:
        print(f"An error occurred: {e}")
        return False

def main(repo_path):
    print(f"Checking if the provided path '{repo_path}' is a valid Git repository")
    # Ensure the provided path is a Git repository
    if not os.path.isdir(os.path.join(repo_path, ".git")):
        print(f"The provided path '{repo_path}' is not a valid Git repository")
        sys.exit(1)
    print("This is a valid git repository -- passed")
    any_changes = has_unstaged_changes()
    if not any_changes:
        print("There are no changes to be staged hence exiting the code !!!")
        sys.exit(1)

    # Pull the latest changes
    run_command("git pull origin main", cwd=repo_path)

    today_str = datetime.now().strftime("%d_%m_%Y__%H_%M")
    print("Listing all branches")
    branches = run_command("git branch --list", cwd=repo_path)
    print(branches)
    print("it is working")
    # Check if there's a branch created today. the below snippet can be deleted if there is no need to use the already created branch
    today_branch = None
    for branch in branches.splitlines():
        branch = branch.strip()
        if today_str in branch:
            today_branch = branch.replace('* ', '')
            break

    if today_branch:
        print(f"Switching to the branch created today: {today_branch}")
        # Switch to the branch created today
        run_command(f"git checkout {today_branch}", cwd=repo_path)
    else:
        # Create a new branch from main
        today_branch = f"Staging_changes_branch_{today_str}"
        print(f"Creating a new branch from main: {today_branch}")
        run_command("git checkout main", cwd=repo_path)
        run_command(f"git checkout -b {today_branch}", cwd=repo_path)
        print(f"Pushing the new branch '{today_branch}' to origin")
        run_command(f"git push origin {today_branch}", cwd=repo_path)

    def run_pre_commit_cycle():
        print("Staging all files")
        # Stage all files
        run_command("git add .", cwd=repo_path)

        print("Running pre-commit hooks")
        # Run pre-commit hooks
        run_command("pre-commit", cwd=repo_path)

        print("Checking status after pre-commit")
        # Check if there are any new changes made by pre-commit
        status_after_precommit = run_command("git status --porcelain", cwd=repo_path)
        run_command("git add .", cwd=repo_path)

    # Run the pre-commit cycle at least three times
    for i in range(3):
        print(f"Running pre-commit cycle {i + 1}")
        run_pre_commit_cycle()

    print("Running pre-commit checks again to ensure everything is clean")
    # Run pre-commit again to ensure everything is clean
    pre_commit_check = subprocess.run("pre-commit", shell=True, cwd=repo_path)
    if pre_commit_check.returncode != 0:
        print("Pre-commit checks failed")
        sys.exit(pre_commit_check.returncode)

    commit_message = "staged content for release"
    print(f"Committing the changes with message: \"{commit_message}\"")
    # Commit the changes with a given message
    run_command(f'git commit -m "{commit_message}"', cwd=repo_path)

    print(f"Pushing the branch '{today_branch}' to origin")
    # Pull the latest changes and rebase before pushing
    run_command(f"git pull --rebase origin {today_branch}", cwd=repo_path)
    run_command(f"git push origin {today_branch}", cwd=repo_path)

    time.sleep(50)

    print("Getting the current highest tag")
    # Get all tags
    tags = run_command("git tag", cwd=repo_path).split('\n')
    highest_tag = get_highest_tag(tags)
    print(f"Current highest tag: {highest_tag}")

    if highest_tag:
        current_tag_number = list(map(int, highest_tag.lstrip('v').split('.')))
        current_tag_number[-1] += 1  # Increment the last part of the version number
        new_tag = 'v' + '.'.join(map(str, current_tag_number))
    else:
        new_tag = "v1.0.0"  # Default to v1.0.0 if no tags are found
    print(f"New tag: {new_tag}")

    print(f"Creating a new tag: {new_tag}")
    # Create the new tag
    run_command(f"git tag {new_tag}", cwd=repo_path)

    print("Running the release notes script")
    # Run the release notes python file and capture the output in release_notes.md
    output_file = "release_notes.md"
    with open(os.path.join(repo_path, output_file), 'w') as f:
        subprocess.run(['python', '.get-apps-release-notes.py'], stdout=f, check=True, cwd=repo_path)

    # Run the pre-commit cycle at least three times after generating release notes
    for i in range(3):
        print(f"Running pre-commit cycle {i + 1} after generating release notes")
        run_pre_commit_cycle()

    print("Running final pre-commit checks to ensure everything is clean")
    # Run pre-commit again to ensure everything is clean
    final_pre_commit_check = subprocess.run("pre-commit", shell=True, cwd=repo_path)
    if final_pre_commit_check.returncode != 0:
        print("Final pre-commit checks failed")
        sys.exit(final_pre_commit_check.returncode)

    final_commit_message = "release notes and final staged content"
    print(f"Committing the final changes with message: \"{final_commit_message}\"")
    # Commit the final changes with a given message
    run_command(f'git commit -m "{final_commit_message}"', cwd=repo_path)

    print(f"Pushing the final changes of branch '{today_branch}' to origin")
    # Pull the latest changes and rebase before pushing
    run_command(f"git pull --rebase origin {today_branch}", cwd=repo_path)
    run_command(f"git push origin {today_branch}", cwd=repo_path)

    print(f"Pushing the new tag '{new_tag}' to origin")
    run_command(f"git push origin {new_tag}", cwd=repo_path)

    # Notify
    print("Changes have been committed, tagged, and pushed to origin")

if __name__ == "__main__":
    repo_path = r"C:\Users\sgbsubhiram.gurlinka\Documents\Middleware\code\trail_automation_repo"
    main(repo_path)
