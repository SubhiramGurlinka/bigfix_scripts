import subprocess

def run_command(command):
    cwd = r"C:\Users\sgbsubhiram.gurlinka\Documents\Middleware\code\trail_automation_repo"
    result = subprocess.run(command, cwd=cwd, capture_output=True, text=True, shell=True)
    return result.stdout.strip().split('\n')

def fetch_tags():
    print("Fetching tags from origin...")
    run_command("git fetch --tags")

def push_tags():
    print("Pushing local tags to origin...")
    run_command("git push --tags")

def get_local_tags():
    return run_command("git tag -l")

def get_remote_tags():
    remote_tags_output = run_command("git ls-remote --tags origin")
    remote_tags = []
    for line in remote_tags_output:
        if line:
            tag = line.split('refs/tags/')[-1]
            if tag.endswith('^{}'):
                tag = tag[:-3]
            remote_tags.append(tag)
    return remote_tags

def delete_local_tag(tag):
    run_command(f"git tag -d {tag}")

def sync_tags():
    fetch_tags()
    # push_tags()

    local_tags = set(get_local_tags())
    remote_tags = set(get_remote_tags())

    tags_to_delete = local_tags - remote_tags

    if tags_to_delete:
        print("Deleting local tags that are not on the remote:")
        for tag in tags_to_delete:
            print(f"Deleting local tag: {tag}")
            delete_local_tag(tag)
    else:
        print("No local tags to delete.")

    print("Tag calibration with origin completed.")

if __name__ == "__main__":
    sync_tags()