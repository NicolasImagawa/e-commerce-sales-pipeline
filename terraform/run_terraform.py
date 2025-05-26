def run_terraform(dir):
    import os
    import subprocess

    terraform_dir = dir
    commands = [
                    ["terraform", "--version"],
                    ["terraform", "init"],
                    ["terraform", "apply", "-auto-approve"]
               ]
    TIMEOUT = 180
    
    for command in commands:
        try:
            print(f"Running {command}")
            subprocess.run(command, cwd=terraform_dir, check=True, text=True, capture_output=True, timeout=TIMEOUT)
            print(f"{command} ran successfully.")
        except subprocess.TimeoutExpired:
            print(f"ERROR - Timeout after {TIMEOUT} seconds.")
        except PermissionError:
            print(f"ERROR - Permission denied, please check if the administrador gave you the correct permissions for this operation.")
        except FileNotFoundError:
            print(f"ERROR - Files not found, please check if main.tf and variables.tf are on {terraform_dir}.")
        except Exception as e:
            print(f"ERROR - An unexpected error has occured: {e}.")